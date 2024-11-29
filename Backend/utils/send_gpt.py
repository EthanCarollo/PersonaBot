from openai import OpenAI

client = OpenAI()

def send_gpt(text):
    response = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": text,
            }
        ],
        model="gpt-4o-mini"
    )
    return response.choices[0].message.content