import subprocess  
import platform  
import json

class GenesisBridge:  
    def \_\_init\_\_(self):  
        self.system \= platform.system()  
        self.node\_name \= platform.node()

    def execute\_task(self, cmd):  
        \# Logování přes ID-86  
        print(f"\[{self.node\_name}\] Executing: {cmd}")  
        try:  
            result \= subprocess.check\_output(cmd, shell=True).decode()  
            return {"status": "success", "output": result}  
        except Exception as e:  
            return {"status": "error", "error": str(e)}

\# Instance pro integraci do LLM  
bridge \= GenesisBridge()  
