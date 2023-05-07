local Translations = {
    error = {
        already_in_test = "You are already in a test.",
        not_enough_money = "You don't have enough money.",
        spawnpoint_blocked = "The spawnpoint is blocked. The money has been refunded.",
        no_route_found = "The route could not be found. The money has been refunded.",
        get_error_pratice = "You have exceeded the speed limit. Error points: ",
        failed = "You have failed the test.",
    },
    success = {
        pay = "You have paid %{first} %{second}.",
        done = "You have passed the test.",
    },
    other = {
        draw_open = "[E] DMV",
        blipRouteName = "DMV Route",
        last_blip = "DMV Route end",
    },
    ui = {
        title = "Driving School",
        titleSmall = "Los Santos",
        practice_finished = "Test finished",
        first_theory = "Not available",
        theory_finished = "Test finished",
        theory_header = "Theory |",
        time = "Time remaining",
        errorpoints = "Error points",
        possibleRightAnswers = "Right answers:",
        possibleErrorPoints = "possible error points:",
        minutes = "minutes",
        seconds = "seconds",
        submit = "Next",
        wrongAnswer = "Wrong answer",
        rightAnswer = "Right answer",
        alreadyHaveLicense = "You already have this license",
        notEnoughMoney = "You don't have enough money",
        finishTheoryFirst = "You have to finish the theory first",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
