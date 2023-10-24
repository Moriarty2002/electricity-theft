# Here we'll write all the functions that connects to the db to retrieve
# the information for the keyboards
from telegram import InlineKeyboardButton


def get_kb_check_start():
    result = []
    # get data from db here
    result = [
        [
            InlineKeyboardButton(text="Abruzzo", callback_data="Abruzzo"),
            InlineKeyboardButton(text="Basilicata", callback_data="Basilicata"),
            InlineKeyboardButton(text="Campania", callback_data="Campania")
        ]
    ]
    return result


def get_kb_city(regione):
    result = []
    # get data from db here filtering by regione
    # for the moment we write it manually
    result = [
        [
            InlineKeyboardButton(text="Avellino", callback_data="Avellino"),
            InlineKeyboardButton(text="Caserta", callback_data="Caserta"),
            InlineKeyboardButton(text="Napoli", callback_data="Napoli")
        ]
    ]

    return result
