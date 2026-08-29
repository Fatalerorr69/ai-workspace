# ai_brain.py
import os
def call_model(prompt, env):
    # Wrapper selecting backend based on env (OPENAI, CLAUDE, GEMINI, LOCAL)
    backend = env.get("MODEL","OPENAI").upper()
    if backend == "OPENAI":
        import openai
        openai.api_key = env.get("OPENAI_API_KEY")
        resp = openai.ChatCompletion.create(model="gpt-4-turbo", messages=[{"role":"user","content":prompt}], temperature=0.2)
        return resp.choices[0].message.content
    # other backends omitted in skeleton for brevity
    return "(no model configured)"
