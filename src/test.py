from ai_assistant import AIAssistant
from ohstem_mqtt import MQTTClient
from tts import TTSHandler
import threading
import time
import re

class SmartHome:
    def __init__(self, mqtt_username="1852837"):
        self.MQTT_USERNAME = mqtt_username
        self.topics = ["V1", "V2", "V3", "V9", "V10", "V12", "V13", "V15", "V16", "V17"]
        self.temperature = None
        self.humidity = None
        self.light = None
        self.led_status = "0"
        self.fan_speed = 0
        self.door_status = "0"
        self.assistant_status = None
        self.current_status = None
        self.voice_result = None

        self.tts_handler = TTSHandler()
        self.assistant = AIAssistant()
        self.client = MQTTClient(self.MQTT_USERNAME, "", "mqtt.ohstem.vn", 1883, self.topics, self.process_message)

    def process_message(self, client, topic, payload):
        # Process the received message
        if topic == self.MQTT_USERNAME + "/feeds/V1":
            self.temperature = float(payload)
            print(f"Received temperature: {self.temperature}")
        elif topic == self.MQTT_USERNAME + "/feeds/V2":
            self.humidity = float(payload)
            print(f"Received humidity: {self.humidity}")
        elif topic == self.MQTT_USERNAME + "/feeds/V3":
            self.light = float(payload)
            print(f"Received light: {self.light}")
        elif topic == self.MQTT_USERNAME + "/feeds/V9":
            self.door_status = str(payload)
            print(f"Received door status: {self.door_status}")
        elif topic == self.MQTT_USERNAME + "/feeds/V10":
            self.led_status = str(payload)
            print(f"Received led status: {self.led_status}")
        elif topic == self.MQTT_USERNAME + "/feeds/V12":
            self.fan_speed = int(payload)
            print(f"Received fan speed: {self.fan_speed}")
        elif topic == self.MQTT_USERNAME + "/feeds/V13":
            self.tts_handler.AI_message = payload
        elif topic == self.MQTT_USERNAME + "/feeds/V15":
            self.tts_handler.AI_command = payload
            print(f"Received AI command: {self.tts_handler.AI_command}")
        elif topic == self.MQTT_USERNAME + "/feeds/V16":
            self.voice_result = payload
            print(f"Received Voice: {self.voice_result}")

        self.current_status = (f"Temperature: {self.temperature} degree Celcius, "
                               f"Humidity: {self.humidity}, "
                               f"Light: {self.light} Lux, "
                               f"LED: {self.led_status}, "
                               f"Fan speed: {self.fan_speed}, "
                               f"Door: {self.door_status}")
        if self.tts_handler.AI_command:
            self.process_ai_command(client) # process AI command that is handled on PC

        if self.voice_result:
            self.ai_response(client)

    # Process AI command
    def process_ai_command(self, client):
        if self.tts_handler.AI_command == "Z":              # Give sensors data
            if self.temperature is not None and self.humidity is not None and self.light is not None:
                output = f"Temperature: {self.temperature} degree Celcius, Humidity: {self.humidity} %, Light: {self.light} Lux"
                client.mqtt_publish("V13", output)

                # Reset the sensor data
                self.temperature = None
                self.humidity = None
                self.light = None

        # Reset AI_command
        self.tts_handler.AI_command = None

    def process_response(self, client, text):
        if self.assistant_status:
            if "STATUS" not in text:
                # Lights
                if any(word in text for word in ["Light", "Lights", "light", "lights", "LED"]):
                    self.process_light_command(client, text)
                # Fan
                if any(word in text for word in ["Fan", "fan"]):
                    self.process_fan_command(client, text)
                # Door
                if any(word in text for word in ["Door", "Doors", "door", "doors", "LED"]):
                    self.process_door_command(client, text)
                # Sensors
                if any(word in text for word in ["Sensor", "Sensors", "sensor", "sensors"]):
                    client.mqtt_publish("V15", "Z")

    def process_light_command(self, client, text):
        if self.contains_word(text, "on") or self.contains_word(text, "on.") or self.contains_word(text, "ON") or self.contains_word(text, "ON."):
            client.mqtt_publish("V15", "S")
        if self.contains_word(text, "off") or self.contains_word(text, "off.") or self.contains_word(text, "OFF") or self.contains_word(text, "OFF."):
            client.mqtt_publish("V15", "s")

    def process_fan_command(self, client, text):
        if "speed" in text or self.contains_word(text, "on") or self.contains_word(text, "to") or self.contains_word(text, "at"):
            match = re.search(r'(\d+)%', text)
            if match:
                self.fan_speed = int(match.group(1))
                client.mqtt_publish("V12", self.fan_speed)
        if self.contains_word(text, "off") or self.contains_word(text, "off.") or self.contains_word(text, "OFF") or self.contains_word(text, "OFF."):
            client.mqtt_publish("V12", 0)

    def process_door_command(self, client, text):
        if any(kw in text for kw in ["opened", "open", "opening", "Opening"]):
            client.mqtt_publish("V15", "T")
        if any(kw in text for kw in ["closed", "close", "closing", "Closing"]):
            client.mqtt_publish("V15", "t")

    def assistant_control(self, text, assistant_status):
        if "hello assistant" in text or "hi assistant" in text:
            return True
        if assistant_status:
            if "bye" in text or "goodbye" in text:
                return False
        return assistant_status

    def generate_prompt(self):
        if any(kw in self.voice_result for kw in ["status", "update", "refresh", "sensor", "sensors"]):
            return "{" + "User prompt: " + self.voice_result + "}" + "{Current system status (DON'T LEAK THIS INTO THE RESPONSE UNLESS BEING ASKED BY THE USER): " + self.current_status + "}"
        return self.voice_result

    def ai_response(self, client, text=""):
        if text == "":
            self.assistant_status = self.assistant_control(self.voice_result, self.assistant_status)
        print(f"Assistant status: {self.assistant_status}")

        if self.assistant_status:
            if text != "":
                prompt = text
            else:
                prompt = self.generate_prompt()
            print(f"Prompt: {prompt}")
            if self.assistant.chat_session == None:
                self.assistant.start_chat()
            response = self.assistant.get_response(prompt)
            self.tts_handler.text_to_speech(response)
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
