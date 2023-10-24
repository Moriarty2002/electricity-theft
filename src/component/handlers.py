from telegram.ext import CommandHandler, MessageHandler, CallbackQueryHandler, filters

from src.component.functions import start, default_response, cb_check, cb_add

# ****** Command handlers *******

cmd_handler_start = CommandHandler('start', start)
# Add the following one as the last, or it will block all the commands
cmd_handler_default = MessageHandler(filters.COMMAND, default_response)


# ****** Callback handlers ******

cb_handler_check_start = CallbackQueryHandler(cb_check, "check_start")

cb_handler_add = CallbackQueryHandler(cb_add, "add")
