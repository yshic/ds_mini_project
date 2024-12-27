from ai_assistant import AIAssistant
from color_library import ColorLibrary
from ohstem_mqtt import MQTTClient
from tts import TTSHandler
import pyaudio
import threading
import time
import re
import os
import keyboard


class SmartHome:
    def __init__(self, mqtt_username="yshic", aio_key=None):
        self.MQTT_USERNAME = mqtt_username
        self.AIO_KEY = aio_key or os.environ.get("AIO_KEY")
        self.topics = ["yshic/feeds/ai-response", "yshic/feeds/door-control", "yshic/feeds/fan-control", "yshic/feeds/humidity",
                       "yshic/feeds/led-colors", "yshic/feeds/led-control", "yshic/feeds/light", "yshic/feeds/temperature", "yshic/feeds/voice-recognition", "yshic/feeds/ai-command"]
        self.temperature = None
        self.humidity = None
        self.light = None
        self.led_status = "0"
        self.led_color = "#ff0000"
        self.fan_speed = 0
        self.door_status = "0"
        self.voice_result = None
        self.assistant_status = None
        self.current_status = None

        self.tts_handler = TTSHandler()
        self.assistant = AIAssistant()
        self.client = MQTTClient(
            self.MQTT_USERNAME, self.AIO_KEY, "io.adafruit.com", 1883, self.topics, self.process_message)

    def process_message(self, client, topic, payload):
        # Process the received message
        if topic == self.MQTT_USERNAME + "/feeds/temperature":
            self.temperature = float(payload)
            print(f"Received temperature: {self.temperature}")
        elif topic == self.MQTT_USERNAME + "/feeds/humidity":
            self.humidity = float(payload)
            print(f"Received humidity: {self.humidity}")
        elif topic == self.MQTT_USERNAME + "/feeds/light":
            self.light = float(payload)
            print(f"Received light: {self.light}")
        elif topic == self.MQTT_USERNAME + "/feeds/door-control":
            self.door_status = str(payload)
            print(f"Received door status: {self.door_status}")
        elif topic == self.MQTT_USERNAME + "/feeds/led-control":
            self.led_status = str(payload)
            print(f"Received LED status: {self.led_status}")
        elif topic == self.MQTT_USERNAME + "/feeds/led-colors":
            self.led_color = str(payload)
            print(f"Received LED color: {self.led_color}")
        elif topic == self.MQTT_USERNAME + "/feeds/fan-control":
            self.fan_speed = int(payload)
            print(f"Received fan speed: {self.fan_speed}")
        elif topic == self.MQTT_USERNAME + "/feeds/ai-command":
            self.tts_handler.AI_command = payload
            print(f"Received AI command: {self.tts_handler.AI_command}")
        elif topic == self.MQTT_USERNAME + "/feeds/voice-recognition":
            self.voice_result = payload
            print(f"Received Voice: {self.voice_result}")

        self.current_status = (f"Temperature: {self.temperature} degree Celcius, "
                               f"Humidity: {self.humidity}, "
                               f"Light: {self.light} Lux, "
                               f"LED: {self.led_status}, "
                               f"Fan speed: {self.fan_speed}, "
                               f"Door: {self.door_status}")
        if self.tts_handler.AI_command:
            # process AI command that is handled on PC
            self.process_ai_command(client)

        if self.voice_result:
            self.ai_response(client)

    def process_ai_command(self, client):
        if self.tts_handler.AI_command == "Z":              # Give sensors data
            if self.temperature is not None and self.humidity is not None and self.light is not None:
                output = f"Temperature: {self.temperature} degree Celcius, Humidity: {self.humidity} %, Light: {self.light} Lux"

                # Reset the sensor data
                self.temperature = None
                self.humidity = None
                self.light = None

        # Reset AI_command
        self.tts_handler.AI_command = None

    def process_response(self, client, text):
        if self.assistant_status:
            if "STATUS" not in text or "I can" not in text:
                # Lights
                if any(word in text for word in ["Light", "Lights", "light", "lights", "LED"]):
                    self.process_light_command(client, text)
                # Fan
                if any(word in text for word in ["Fan", "fan"]):
                    self.process_fan_command(client, text)
                # Door
                if any(word in text for word in ["Door", "Doors", "door", "doors"]):
                    self.process_door_command(client, text)
                # Sensors
                if any(word in text for word in ["Sensor", "Sensors", "sensor", "sensors"]):
                    client.mqtt_publish("ai-command", "Z")

    def process_light_command(self, client, text):
        if self.contains_word(text, "on") or self.contains_word(text, "on."):
            client.mqtt_publish("led-control", "1")
            return
        if self.contains_word(text, "off") or self.contains_word(text, "off."):
            client.mqtt_publish("led-control", "0")
            return
        if any(word in text for word in ["color", "Color", "colors", "Colors", "led color", "light color"]):
            self.process_led_color_command(client, text)

    def process_led_color_command(self, client, text):
        for color in ColorLibrary.color_map.keys():
            if color in text.lower():
                hex_code = ColorLibrary.get_hex(color)
                client.mqtt_publish("led-colors", hex_code)
                print(f"Setting LED color to {color} ({hex_code})")
                break

    def process_fan_command(self, client, text):
        if self.contains_word(text, "?") or "What" in text or "what" in text or "e.g." in text or "example" in text:
            return
        else:
            if "speed" in text or self.contains_word(text, "on") or self.contains_word(text, "to") or self.contains_word(text, "at"):
                match = re.search(r'(\d+)%', text)
                if match:
                    self.fan_speed = int(match.group(1))
                    client.mqtt_publish("fan-control", self.fan_speed)

        if self.contains_word(text, "off") or self.contains_word(text, "off."):
            client.mqtt_publish("fan-control", 0)

    def process_door_command(self, client, text):
        if any(kw in text for kw in ["Opening", "opened", "open", "opening"]):
            client.mqtt_publish("ai-command", "T")
        if any(kw in text for kw in ["Closing", "closed", "close", "closing"]):
            client.mqtt_publish("ai-command", "t")

    def assistant_control(self, text, assistant_status):
        if "hello assistant" in text or "hi assistant" in text:
            return True
        if assistant_status:
            if "bye" in text or "goodbye" in text:
                return False
        return assistant_status

    def check_status_prompt(self, text=""):
        if any(kw in self.voice_result for kw in ["status", "update", "refresh", "sensor", "sensors"]):
            return "{" + "User prompt: " + self.voice_result + "}" + "{Current system status (DON'T LEAK THIS INTO THE RESPONSE UNLESS BEING ASKED BY THE USER): " + self.current_status + "}"
        return self.voice_result

    def ai_response(self, client, text=""):
        if text == "":
            self.assistant_status = self.assistant_control(
                self.voice_result, self.assistant_status)
        print(f"Assistant status: {self.assistant_status}")

        if self.assistant_status:
            if text != "":
                prompt = text
            else:
                prompt = self.check_status_prompt()
            print(f"Prompt: {prompt}")
            if self.assistant.chat_session == None:
                self.assistant.start_chat()
            response = self.assistant.get_response(prompt)
            self.tts_handler.text_to_speech(response)
            client.mqtt_publish("ai-response", response)
            print(f"Response: {response.encode('utf-8')}")
            self.process_response(client, response)

        # Reset voice_result
        self.voice_result = None

    @staticmethod
    def contains_word(text, word):
        words = text.split()
        return word in words

    def run(self):
        while True:
            time.sleep(1)


if __name__ == "__main__":
    system = SmartHome()
    system.run()
