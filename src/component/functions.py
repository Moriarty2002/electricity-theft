from telegram import Update
from telegram.ext import ContextTypes

from src.component.keyboard import *


# ****** Commands ******
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(
        chat_id=update.effective_chat.id,
        text="Ciao {},\ncosa vuoi fare?".format(update.message.chat.first_name),
        reply_markup=kb_start
    )


async def default_response(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=update.effective_chat.id, text="Scusami,\nnon ho capito il tuo comando")


# ****** Callbacks ******


async def cb_check(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(
        chat_id=update.effective_chat.id,
        text="Seleziona la tua regione",
        reply_markup=kb_check_start
    )
    await context.bot.answerCallbackQuery(callback_query_id=update.callback_query.id)


async def cb_add(update: Update, context: ContextTypes.DEFAULT_TYPE):
    # TODO: Check if exists a better auth method
    await context.bot.send_message(
        chat_id=update.effective_chat.id,
        text="Per aggiungere una bolletta devi autenticarti",
        reply_markup=kb_auth
    )
    await context.bot.answerCallbackQuery(callback_query_id=update.callback_query.id)
