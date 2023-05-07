local Translations = {
    error = {
        already_in_test = "Du bist bereits in einem Test.",
        not_enough_money = "Du hast nicht genug Geld.",
        spawnpoint_blocked = "Der Spawnpoint ist blockiert. Das Geld wurde erstattet.",
        no_route_found = "Die Route konnte nicht gefunden werden. Das Geld wurde erstattet.",
        get_error_pratice = "Du hast die Geschwindigkeitsbegrenzung überschritten. Fehlerpunkte: ",
        failed = "Du hast den Test nicht bestanden.",
    },
    success = {
        pay = "Du hast %{first} %{second} bezahlt.",
        done = "Du hast den Test bestanden.",
    },
    other = {
        draw_open = "[E] Fahrschule",
        blipRouteName = "Fahrschulroute",
        last_blip = "Fahrschulroute Ende",
    },
    ui = {
        title = "Fahrschule",
        titleSmall = "Los Santos",
        practice_finished = "Test beendet",
        first_theory = "Nicht verfügbar",
        theory_finished = "Test beendet",
        theory_header = "Theorietest |",
        time = "Verbleibende Zeit",
        errorpoints = "Fehlerpunkte",
        possibleRightAnswers = "Richtige Antworten:",
        possibleErrorPoints = "mögliche Fehlerpunkte:",
        minutes = "Minuten",
        seconds = "Sekunden",
        submit = "Weiter",
        wrongAnswer = "Falsche Antwort",
        rightAnswer = "Richtige Antwort",
        alreadyHaveLicense = "Du hast bereits diese Lizenz",
        notEnoughMoney = "Du hast nicht genug Geld",
        finishTheoryFirst = "Du musst zuerst die Theorie abschließen",
    }
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
