import time
import statistics
from datetime import datetime
from robot.api import logger
from typing import Any, Callable, Tuple, Union
from robot.libraries.BuiltIn import BuiltIn

class PerformanceMetrics:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self):
        self._builtin = BuiltIn()
        self._timings = {}

    # testar a velocidade de execução de um keyword/endpoint/função
    def measure_execution(
        self,
        keyword: Union[str, Callable], # keyword a ser testado
        *args: Any, # argumentos da keyword (se necessário)
        **kwargs: Any
    ) -> Tuple[Any, float]:
        
        start_time = time.perf_counter()
        
        try:
            keyword_func = self._resolve_keyword(keyword)
            result = keyword_func(*args, **kwargs)
        except Exception as e:
            duration = time.perf_counter() - start_time
            self._log_measurement(keyword, duration, False)
            raise
            
        duration = time.perf_counter() - start_time
        self._log_measurement(keyword, duration, True)
        
        return result, duration
    
    # função para resolver uma keyword do Robot Framework para uma função
    def _resolve_keyword(self, keyword: Union[str, Callable]) -> Callable:
        if callable(keyword):
            return keyword
            
        if isinstance(keyword, str):
            if hasattr(self._builtin, keyword):
                return getattr(self._builtin, keyword)
            
            if '.' in keyword:
                lib_name, kw_name = keyword.split('.', 1)
                try:
                    lib = self._builtin.get_library_instance(lib_name)
                    return getattr(lib, kw_name)
                except:
                    pass
            
            return lambda *a, **kw: self._builtin.run_keyword(keyword, *a, **kw)
        
        raise ValueError(f"Não foi possível resolver '{keyword}' para uma função")
    
    def _log_measurement(
        self,
        keyword: Union[str, Callable],
        duration: float,
        success: bool
    ) -> None:
        kw_name = (
            keyword.__name__ if callable(keyword)
            else str(keyword)
        )
        
        self._timings.setdefault(kw_name, []).append({
            'timestamp': time.time(),
            'duration': duration,
            'success': success
        })
        
        logger.info(
            f"⏱️ {kw_name} - {duration:.4f}s - {'SUCCESS' if success else 'FAILED'}"
        )
        
    # buscar estatísticas de tempo de execução para um keyword específico
    def get_timing_stats(self, keyword: str) -> dict:
        timings = self._timings.get(keyword, [])
        
        if not timings:
            return {}
            
        durations = [t['duration'] for t in timings]
        return {
            'count': len(timings),
            'successes': sum(1 for t in timings if t['success']),
            'failures': sum(1 for t in timings if not t['success']),
            'average': sum(durations) / len(durations),
            'min': min(durations),
            'max': max(durations),
            'last_10': durations[-10:]
        }