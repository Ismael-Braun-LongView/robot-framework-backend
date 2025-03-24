import requests
from robot.api import logger

class AuthLibrary:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self, base_url):
        self.auth_endpoint = "/api/v1/token/"
        self.base_url = base_url
        self.token = None
        
    def login(self, cpfcnpj, password):
        data = {
            "cpfcnpj": cpfcnpj,
            "password": password
        }
        try:
            response = requests.post(f"{self.base_url}{self.auth_endpoint}", json=data, timeout=10)
            response.raise_for_status()
            
            self.token = response.json().get('access')
            if not self.token:
                raise ValueError("Sem token de acesso retornado na resposta.")
                
            logger.info(f"Logado com sucesso. Token: {self.token[:15]}...")
            return self.token
            
        except requests.exceptions.RequestException as e:
            error_msg = f"O login falhou: {str(e)}"
            if hasattr(e, 'response') and e.response:
                error_msg += f"\nResponse: {e.response.text}"
            logger.error(error_msg)
            raise AssertionError(error_msg)
        
    def get_token(self):
        return self.token
        
    def get_auth_headers(self):
        if not self.token:
            raise RuntimeError("Token de acesso não encontrado. Faça login primeiro.")
            
        return {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }