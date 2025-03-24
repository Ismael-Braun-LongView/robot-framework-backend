from robot.api.deco import keyword
import requests
from robot.api import logger

class ProposalLibrary:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self, base_url):
        self.base_url = base_url
        self.token = None
        self.proposals_endpoint = "/api/v1/proposals/"
        
    def criar_proposta(self, proposal_data):
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }
        try:
            response = requests.post(
                f"{self.base_url}{self.proposals_endpoint}",
                json=proposal_data,
                headers=headers,
                timeout=10
            )
            #response.raise_for_status()
            return response
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Erro ao criar proposta: {str(e)}")
            if hasattr(e, 'response') and e.response:
                logger.error(f"Detalhes do erro: {e.response.text}")
            raise
      
    def procurar_proposta(self, **filters):
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }
        
        if not filters:
            raise ValueError("Filtro vazio, informe ao menos um parâmetro.")
            
        response = requests.get(
            f"{self.base_url}{self.proposals_endpoint}",
            params=filters,
            headers=headers,
            timeout=10
        )
        
        #response.raise_for_status()
        return response
        
    @keyword(name="Set Token")
    def set_token(self, new_token):
        self.token = new_token