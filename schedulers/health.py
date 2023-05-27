import logging
logging.basicConfig(format='%(module)-10s | %(asctime)s | %(levelname)-8s | %(message)s', level=logging.INFO, datefmt="%Y-%m-%dT%H:%M:%S")
logger = logging.getLogger('health')
logger.info("")
logger.info("---------------------------------------------------------------------------------------------")
logger.info("                                        Hello World!")
logger.info("                                       Health Check OK")
logger.info("---------------------------------------------------------------------------------------------")
logger.info("")
