import requests
from json.decoder import JSONDecodeError

import conf.config as config
    

class EpOnlineService():
    """
    Setup a basic service to connect to EP-Online
    """
    def __init__(self):
        self.session = SessionWithUrlBase(
            url_base=config.BASE_URLS['EP_ONLINE'], 
            api_key=config.API_KEYS['EP_ONLINE'])

    def __call__(self, *args, **kwargs):
        raise NotImplementedError()

    @classmethod
    def execute(cls, *args, **kwargs):
        """
        Creates a new Service and executes it
        """
        service = cls()
        return service.__call__(*args, **kwargs)
    
    
class QueryEnergyLabel(EpOnlineService):
    """
    TODO
    """
    def __call__(self, bag_id):
        """
        bag_id    the building's BAG VBO (verblijfsobject) ID
        
        Returns json response
        """
        response = self.session.get(
            f"/PandEnergielabel/AdresseerbaarObject/{bag_id}",
            headers={'Connection': 'close'}
        )

        return self.__handle_response(response)

    
    def __handle_response(self, response):
        """
        Returns a service result, by which we can check later if it's a success or not
        """
        if response.ok:
            value = response.json()

            return ServiceResult.success(value)
        try:
            # Check if any errors are returned
            return ServiceResult.failure(response.json())
        except JSONDecodeError:
            return ServiceResult.failure([f"EP-Online returned a {response.status_code}"])

        
class SessionWithUrlBase(requests.Session):
    """
    Helper class to store the base url
    """

    def __init__(self, url_base=None, api_key=None, *args, **kwargs):
        super(SessionWithUrlBase, self).__init__(*args, **kwargs)
        self.url_base = url_base
        self.api_key = api_key
        

    def request(self, method, url, headers={}, **kwargs):
        modified_url = self.url_base + url
        
        headers['Authorization'] = f"Bearer {self.api_key}"

        return super(SessionWithUrlBase, self).request(
            method, modified_url, headers=headers, **kwargs)
    
    
class ServiceResult():
    """
    Used as an object returned by services, holds values and errors
    """
    def __init__(self, successful=True, errors=None, value=None):
        self.errors = errors
        self.value = value
        self.successful = successful

    @classmethod
    def failure(cls, errors=None):
        """
        Creates a new (success=False) instance, containing the errors (list-like)
        """
        return cls(successful=False, errors=errors)

    @classmethod
    def success(cls, value=None):
        """
        Creates a successfull ServiceResult with value as value
        """
        return cls(value=value)