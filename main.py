import logging

from telegram.ext import ApplicationBuilder

from component.constraints import BOT_TOKEN
from component.handlers import *

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFOt
)

if __name__ == '__main__':
    application = ApplicationBuilder().token(BOT_TOKEN).build()

    application.add_handlers([cmd_handler_start, cmd_handler_default, cb_handler_check_start])

    application.run_polling()
#FORZA NAPOLI