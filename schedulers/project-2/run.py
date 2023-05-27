import sys
import logging

logging.basicConfig(format='%(name)-10s | %(asctime)s | %(levelname)s | %(message)s', level=logging.INFO, datefmt="%Y-%m-%dT%H:%M:%S.000Z")
logger = logging.getLogger('project-2')


def get_base_prefix_compat():
    """Get base/real prefix, or sys.prefix if there is none."""
    return getattr(sys, "base_prefix", None) or getattr(sys, "real_prefix", None) or sys.prefix


def in_virtualenv():
    return get_base_prefix_compat() != sys.prefix


logger.info("{0} | Is {0} uses a venv?: {1}".format(__file__, in_virtualenv()))
logger.info("{0} | Base Prefix {1}".format(__file__, getattr(sys, "base_prefix", None)))
logger.info("{0} | Real Prefix {1}".format(__file__, getattr(sys, "real_prefix", None)))
logger.info("{0} | Sys Prefix  {1}".format(__file__, sys.prefix))
logger.info("{0} | What args the {0} script has?: {1}".format(__file__, sys.argv[1:]))
logger.info("")
