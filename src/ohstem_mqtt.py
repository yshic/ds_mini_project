import paho.mqtt.client as mqtt
import time


class MQTTClient:
    def __init__(self, username, password, server, port, topics, message_callback):
        self.MQTT_SERVER = server
        self.MQTT_PORT = port
        self.MQTT_USERNAME = username
        self.MQTT_PASSWORD = password
        self.topics = topics
        self.message_callback = message_callback

        self.mqttClient = mqtt.Client()
        self.mqttClient.username_pw_set(self.MQTT_USERNAME, self.MQTT_PASSWORD)
        self.mqttClient.connect(self.MQTT_SERVER, int(self.MQTT_PORT), 60)

        # Register mqtt events
        self.mqttClient.on_connect = self.mqtt_connected
        self.mqttClient.on_subscribe = self.mqtt_subscribed
        self.mqttClient.on_message = self.mqtt_recv_message

        self.mqttClient.loop_start()

    def mqtt_connected(self, client, userdata, flags, rc):
        print("Connected succesfully!!")
        for topic in self.topics:
            client.subscribe(topic)

    def mqtt_subscribed(self, client, userdata, mid, granted_qos):
        print("Subscribed to Topic!!!")

    def mqtt_recv_message(self, client, userdata, message):
        payload = message.payload.decode("utf-8")
        topic = message.topic
        self.message_callback(self, topic, payload)

    def mqtt_publish(self, topic, payload):
        topic = self.MQTT_USERNAME + "/feeds/" + topic
        self.mqttClient.publish(topic, payload)


if __name__ == "__main__":
    topics = ["yshic/feeds/ai-response", "yshic/feeds/door-control", "yshic/feeds/fan-control", "yshic/feeds/humidity",
                       "yshic/feeds/led-colors", "yshic/feeds/ledcontrol", "yshic/feeds/light", "yshic/feeds/temperature", "yshic/feeds/voice-recognition"]
    client = MQTTClient("yshic", "", "io.adafruit.com", 1883, topics)

    while True:
        time.sleep(1)
