import logging
from logging.handlers import TimedRotatingFileHandler
import warnings
import os
from datetime import datetime

LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s'
LOG_FOLDER = 'log'

if not os.path.exists(LOG_FOLDER):
    os.makedirs(LOG_FOLDER)

GOOD_LEVEL = 25
logging.addLevelName(GOOD_LEVEL, "GOOD")

def good(self, message, *args, **kwargs):
    if self.isEnabledFor(GOOD_LEVEL):
        self._log(GOOD_LEVEL, message, args, **kwargs)

logging.Logger.good = good

class CustomTimedRotatingFileHandler(TimedRotatingFileHandler):
    def get_log_filename(self):
        date_str = datetime.now().strftime('%Y-%m-%d')
        return os.path.join(LOG_FOLDER, f'{date_str}.log')

    def doRollover(self):
        self.stream.close()
        self.remove_old_log_files()
        self.baseFilename = self.get_log_filename()
        self.stream = self._open()

    def remove_old_log_files(self):
        files = [f for f in os.listdir(LOG_FOLDER) if f.endswith('.log')]
        files.sort(reverse=True)
        while len(files) > self.backupCount:
            file_to_remove = files.pop()
            os.remove(os.path.join(LOG_FOLDER, file_to_remove))

class FilterWarnings(logging.Filter):
    def filter(self, record):
        if 'torchaudio._backend.set_audio_backend' in record.getMessage():
            return False
        return True

class ColoredFormatter(logging.Formatter):
    def format(self, record):
        log_colors = {
            'WARNING': '\033[93m',
            'ERROR': '\033[91m',
            'CRITICAL': '\033[91m',
            'GOOD': '\033[92m',  # Green color for GOOD level
            'RESET': '\033[0m'
        }
        if record.levelname in log_colors:
            record.msg = f"{log_colors[record.levelname]}{record.msg}{log_colors['RESET']}"
        return super().format(record)

def configure_logger():
    logger = logging.getLogger("persona_bot")
    logger.propagate = False
    if logger.hasHandlers():
        logger.handlers.clear()
    log_level = logging.INFO
    logger.setLevel(log_level)
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(ColoredFormatter(LOG_FORMAT))

    file_handler = CustomTimedRotatingFileHandler(
        filename=os.path.join(LOG_FOLDER, 'initial.log'), 
        when='midnight', 
        interval=1, 
        backupCount=15
    )
    file_handler.setFormatter(logging.Formatter(LOG_FORMAT))
    logger.addHandler(file_handler)

    console_handler.addFilter(FilterWarnings())
    logger.addHandler(console_handler)
    
    logger.info(" SETUP LOGGER, will save the log file in file : " + file_handler.get_log_filename())
    
    logging.captureWarnings(True)
    warnings.filterwarnings('ignore', category=UserWarning, module='torchaudio.*')

    return logger