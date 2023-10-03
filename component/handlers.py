from telegram.ext import CommandHandler, MessageHandler, CallbackQueryHandler, filters
from component.functions import *

# ****** Command handlers *******

cmd_handler_start = CommandHandler('start', start)
# Add the following one as the last, or it will block all the commands
cmd_handler_default = MessageHandler(filters.COMMAND, default_response)


# ****** Callback handlers ******

cb_handler_check_start = CallbackQueryHandler(cb_check, "check_start")
