from telegram import InlineKeyboardMarkup, InlineKeyboardButton

from connector.kb_utils import get_kb_check_start

#TODO: Aggiungere query per ritrovare filtri su regione

# ****** Buttons ******

btn_add_start = InlineKeyboardButton(text="Aggiungi nuova bolletta", callback_data="add")
btn_check_start = InlineKeyboardButton(text="Confronta prezzi fornitori", callback_data="check_start")

# ****** Keyboards ******

kb_start = InlineKeyboardMarkup([[btn_add_start], [btn_check_start]])
kb_check_start = InlineKeyboardMarkup(get_kb_check_start())

