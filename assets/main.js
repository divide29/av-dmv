// variables
let activateDebug = false;
let isInTest = false;
let questionsArray = [];
let possibleSpawnPoints = [];
let currentQuestionsArray = [];
let errorPoints = 0;
let maxErrorPoints = 0;
let questionNumber = 1;
let timeLeft = 180;
let Lang

feather.replace();

function closeNui() {
    $("#av_dmv_main").addClass("hidden");
    $("#av_dmv_main").removeClass("grid");

    $.post("https://av-dmv/handleNui", JSON.stringify({
        handle: 0
    }));
}

// function for finish theory test
function finishTheoryTest(license) {
    if (activateDebug == true) {
        console.log("avellon | Finish theory test");
    }

    // post data to finish theory test nui
    $.post("https://av-dmv/finishTheoryTest", JSON.stringify({
        license
    }));
}

/**
 * @param  {integer} pageNumber
 */
function openPage(pageNumber) {
    const pages = [
        "#av_dmv_page_start",
        "#av_dmv_page_theory",
    ];
    pages.forEach((page, index) => {
        if (index === pageNumber) {
            $(page).removeClass("hidden");
            $(page).addClass("flex");
        } else {
            $(page).addClass("hidden");
            $(page).removeClass("flex");
        }
    });
    switch (pageNumber) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
    }
}

function createNotification(type, message) {
    $(".notification").remove();

    // add icons to notification from feather
    if (type == "success") {
        message = `<i data-feather="check-circle"></i> <p style="margin-bottom: 0rem !important; margin-left: 0.4rem !important;">${message}<p>`;
    } else if (type == "danger") {
        message = `<i data-feather="x-circle"></i> <p style="margin-bottom: 0rem !important; margin-left: 0.4rem !important;">${message}<p>`;
    }

    let style = "green-700";
    if (type == "danger") {
        style = "red-700";
    }

    console.log(style)

    const notification = document.createElement("div");
    notification.innerHTML = message;
    notification.classList.add("notification", "fixed", "flex", "items-center", "text-white", "top-7", "left-1/2", "transform", "-translate-x-1/2", "z-50", "text-sm", "font-medium", "px-1", "py-1", "m-1", `bg-${style}`, "rounded-lg", "mb-0");

    document.body.appendChild(notification);

    feather.replace();

    setTimeout(() => notification.remove(), 5000);
}

// function to end the test
function endTest(hasPassed) {
    if (!isInTest) return;

    clearInterval(timer);
    isInTest = false;
    questionsArray = [];
    currentQuestionsArray = [];
    questionNumber = 1;
    errorPoints = 0;
    maxErrorPoints = 0;
    timeLeft = 180;

    createNotification(hasPassed ? "success" : "danger",
      hasPassed ? "Du hast den Test bestanden." : "Du hast den Test nicht abgeschlossen.");

    closeNui();
}

function setupLicenses(possibleLicenses, hasTheoryLicenses, hasPracticeLicenses) {
    const av_dmv_page_start_left = $("#av_dmv_page_start_left");
    const av_dmv_page_start_right = $("#av_dmv_page_start_right");

    av_dmv_page_start_left.empty();
    av_dmv_page_start_right.empty();

    function createLicenseContainer(license, type) {
      const licenseContainer = $(`<div id="av_dmv_list_${type}_${license.class}" class="license-container col col-3 h-50 p-3"></div>`);
      const licenseContainer2 = $(`<div class="box bg-box rounded p-3 text-white bg-box-row"></div>`);
      const licenseTitle = $(`<h3 class="license-title">${license.name}</h3>`);
      const licensePrice = $(`<h3 class="license-price">${license.theoryFee} €</h3>`);

      licenseContainer2.append(licenseTitle, licensePrice);
      licenseContainer.append(licenseContainer2);

      return licenseContainer;
    }

    function addOverlay(container, text) {
      const licenseOverlay = $("<div class='bg-gray-800 -mt-14 ml-6 p-2 text-white'></div>").html(`<h5 class='license-title'>${text}</h5>`);

      licenseOverlay.css({
        position: "absolute",
        zIndex: "1"
      });

      container.append(licenseOverlay)

      // add to first child div of container the class opacity-50
      container.find("div:first-child").addClass("opacity-50");
      container.addClass("disabled-overlay");
    }

    function removeOverlay(container) {
        container.find("div:first-child").removeClass("opacity-50");
        container.find(".disabled-overlay").remove();
    }

    for (const possibleLicense of possibleLicenses) {
      // create theory license container
      const theoryLicenseContainer = createLicenseContainer(possibleLicense, "theory");
      av_dmv_page_start_left.append(theoryLicenseContainer);

      if (activateDebug) {
        console.log(`avellon | Add theory licenses to menu: \n avellon | Name = ${possibleLicense.class}`);
      }

      // create practice license container
      const practiceLicenseContainer = createLicenseContainer(possibleLicense, "practice");
      av_dmv_page_start_right.append(practiceLicenseContainer);

      if (activateDebug) {
        console.log(`avellon | Add practice licenses to menu: \n avellon | Name = ${possibleLicense.class}`);
      }

      // check if hasTheoryLicense is not present for each in possibleLicenses then disable the practice
        if (!hasTheoryLicenses.includes(possibleLicense.class + "_theory")) {
            addOverlay(practiceLicenseContainer, "Theory test not completed");
        }

        if (hasTheoryLicenses.includes(possibleLicense.class + "_theory")) {
            addOverlay(theoryLicenseContainer, "Theory test completed");
            removeOverlay(practiceLicenseContainer);
        }

        // check if hasPracticeLicense is present then deactivate the practice
        if (hasPracticeLicenses.includes(possibleLicense.class + "_practice")) {
            addOverlay(practiceLicenseContainer, "Practice test not completed");
        }
    }
  }

// function to display the question
function displayQuestions(currentQuestionsArray, maxErrorPoints, licenseTitle, license) {
    $("[id^='ds2_question_']").remove();
    let randomQuestion = currentQuestionsArray[Math.floor(Math.random() * currentQuestionsArray.length)];
    let randomQuestionIndex = currentQuestionsArray.indexOf(randomQuestion);

    // print current questions array
    if (activateDebug == true) {
        console.log("avellon | Current questions array: " + currentQuestionsArray);
    }

    if (!currentQuestionsArray.length) {
        endTest(true);
        finishTheoryTest(license);
        return;
    }

    const questionContainer2 = document.createElement("div");
    questionContainer2.classList.add("bg-box", "rounded", "p-3", "text-white", ".bg-box-row");
    questionContainer2.id = `ds2_question_${randomQuestion.id}`;
    questionContainer2.innerHTML = `
    <h5 id="ds2_question_title" style="color: white;" class="question-title"></h5>
    <div id="ds2_question_answers" class="question-answers">
                 <div id="ds2_question_A" class="question-answer">
                     <input type="checkbox" id="answer_a" value="A">
                     <label style="color: white;" for="answer_a"> ${randomQuestion.answerA}</label>
                 </div>
                 <div id="ds2_question_B" class="question-answer">
                     <input type="checkbox" id="answer_b" value="B">
                     <label style="color: white;" for="answer_b"> ${randomQuestion.answerB}</label>
                 </div>
                 <div id="ds2_question_C" class="question-answer">
                     <input type="checkbox" id="answer_c" value="C">
                     <label style="color: white;" for="answer_c"> ${randomQuestion.answerC}</label>
                 </div>
                 <div id="ds2_question_D" class="question-answer">
                     <input type="checkbox" id="answer_d" value="D">
                     <label style="color: white;" for="answer_d"> ${randomQuestion.answerD}</label>
                 </div>
             </div>
                `;
    $("#av_dmv_page_theory").append(questionContainer2);


    const submitButton = document.createElement("button");
    submitButton.classList.add("w-1/6", "mt-3", "focus:ring-blue-800", "bg-blue-500", "text-white", "border-blue-500", "mb-2", "mr-2", "text-center", "py-2.5", "px-5", "text-sm", "rounded-lg", "font-medium", "focus:ring-blue-300", "focus:outline-none", "focus:ring-4", "border-blue-700", "border");
    submitButton.id = "ds2_question_submit";
    submitButton.innerHTML = "Weiter";

    const onSubmitButtonClick = function () {
        const checkedBoxesValues = [];
        $("input:checkbox:checked").each(function () {
            checkedBoxesValues.push($(this).val());
        });

        console.log("Max error points in displayQuestions: " + maxErrorPoints);
        let checkAnswer = checkAnswers(checkedBoxesValues, randomQuestion.rightAnswers, randomQuestion.errorPoints, maxErrorPoints, questionNumber)
        if (checkAnswer) {
            if (currentQuestionsArray.length > 0) {
                currentQuestionsArray.splice(randomQuestionIndex, 1);
                displayQuestions(currentQuestionsArray, maxErrorPoints, licenseTitle, license);
                questionNumber++;
            }
        }
    };

    submitButton.addEventListener("click", onSubmitButtonClick);
    $("#av_dmv_page_theory").append(submitButton);

    // get the entries number of the right answers array
    let rightAnswersText = randomQuestion.rightAnswers.length;
    $("#ds2_question_title").html(`${randomQuestion.question}<br/><span class="text-sm">Richtige Antwortmöglichkeiten: ${rightAnswersText}, mögliche Fehlerpunkte: ${randomQuestion.errorPoints}</span>`);
}

// function to check if the checked checkboxes array is equal to the right answers array
function checkAnswers(checkedAnswers, rightAnswers, questionErrorPoints, maxErrorPoints, questionNumber) {
    checkedAnswers.sort();
    rightAnswers.sort();

    const isCorrect = JSON.stringify(checkedAnswers) === JSON.stringify(rightAnswers);
    console.log(questionNumber)

    $("#av_dmv_theory_answeredQuestionsBox_" + questionNumber).addClass(!isCorrect ? "border-2 border-red-400" : "border-2 border-green-400");
    createNotification(isCorrect ? "success" : "danger", isCorrect ? "Diese Antwort ist richtig." : "Diese Antwort ist falsch.");

    if (!isCorrect) {
      errorPoints += questionErrorPoints;
      $("#av_dmv_theory_errorpointsText").text(`${errorPoints} / ${maxErrorPoints}`);
      if (errorPoints >= maxErrorPoints) endTest(0);
    }

    return true;
  }

// function to start practice Test
function startPracticeTest(license) {
    closeNui();
    $.post("https://av-dmv/startPracticeTest", JSON.stringify({
        license,
        possibleSpawnPoints
    }));
}

function startTheoryTest(license, questions, licenseTitle) {
    if (isInTest) {
      createNotification("danger", "Du bist bereits in einem Test!");
      return;
    }
    isInTest = true;

    $("#av_dmv_page_theory").empty();
    const title = $("<h1>", {
      "class": "text-left mb-1",
      "id": "av_dmv_theory_title",
      "text": `Theorietest | ${licenseTitle}`
    });
    $("#av_dmv_page_theory").append(title);

    $("[id^='av_dmv_page_start_left'], [id^='av_dmv_page_start_right']").empty();

    const answeredQuestionsContainer = $("<div>", {
      "class": "flex flex-row justify-center mt-8 mb-8 w-full h-5 flex-wrap",
      "id": "av_dmv_theory_answeredQuestionsContainer"
    });
    $("#av_dmv_page_theory").append(answeredQuestionsContainer);

    maxErrorPoints = 0;
    currentQuestionsArray = [];

    for (const question of questions) {
      if (question.forLicense === license) {
        maxErrorPoints = question.maxErrorPoints;
        for (let j = 1; j < question.questions.length && currentQuestionsArray.length < question.maxQuestions; j++) {
          currentQuestionsArray.push(question.questions[j]);
          $("#av_dmv_theory_answeredQuestionsContainer").append(`
            <div class="ml-2 text-white border-2 text-center w-6 h-6 rounded-md" id="av_dmv_theory_answeredQuestionsBox_${j}">
              <p class="av_dmv_theory_answeredQuestionsBox_number">${j}</p>
            </div>
          `);
        }
        break;
      }
    }


    timer = setInterval(() => {
      if (timeLeft > 0) {
        $("#av_dmv_theory_timerText").text(`${Math.floor(timeLeft / 60)} Minuten ${timeLeft % 60} Sekunden`);
        timeLeft--;
      } else {
        console.log("Time is up!");
        endTest(0);
      }
    }, 1000);

    const timerContainer = $("<div>", {
      "class": "av_dmv_theory_timerContainer p-3 rounded",
      "html": `
        <h5 style="color: white;" class="av_dmv_theory_timerTitle">Zeit verbleibend</h5>
        <div class="av_dmv_theory_timerTextContainer">
          <p id="av_dmv_theory_timerText" style="color: white;">3 Minuten</p>
        </div>
      `
    });

    const errorPointsContainer = $("<div>", {
      "class": "av_dmv_theory_errorpointsContainer p-3 rounded",
      "html": `
        <h5 style="color: white;" class="av_dmv_theory_errorpointsTitle">Fehlerpunkte</h5>
        <div class="av_dmv_theory_errorpointsTextContainer">
          <p id="av_dmv_theory_errorpointsText" style="color: white;">0 / ${maxErrorPoints}</p>
        </div>
      `
    });

    const flexContainer = $("<div>", {
      "class": "d-flex flex-row justify-content-between mb-3",
      "id": "av_dmv_theory_errorAndTimerContainer"
    }).append(timerContainer, errorPointsContainer);

    $("#av_dmv_page_theory").append(flexContainer);

    displayQuestions(currentQuestionsArray, maxErrorPoints, licenseTitle, license);
    openPage(1)
  }

// on click in every license container which start with liicense-
$(document).on("click", "div[id^='av_dmv_list_theory_']", function () {
    const $this = $(this);

    if ($this.hasClass("disabled-overlay")) {
      return createNotification("danger", "Du hast diese Lizenz bereits!");
    }

    const licenseName = $this.attr("id").replace("av_dmv_list_theory_", "");
    const licenseTitle = $this.find(".license-title").text();
    const fee = parseInt($this.find(".license-price").text().replace("€", "").replace(/\s+/g, ""));

    $.post("https://av-dmv/startTheoryTest", JSON.stringify({ fee }), function (response) {
      if (response) {
        startTheoryTest(licenseName, questionsArray, licenseTitle);
      } else {
        createNotification("danger", "Du hast nicht genug Geld!");
      }
    });
  });


  $(document).on("click", "div[id^='av_dmv_list_practice_']", function () {
    const $this = $(this);

    if ($this.hasClass("disabled-overlay")) {
      return createNotification("danger", "Du musst zuerst die Theorieprüfung bestehen.");
    }

    const licenseName = $this.attr("id").replace("ds2_practice_menu_license_", "");
    startPracticeTest(licenseName);
  });

$(document).on("click", "#av_dmv_close > svg", function () {
    endTest(0);
    closeNui();
});


const handleMessage = (event) => {
    const item = event.data;
    questionsArray = item.questions;
    possibleSpawnPoints = item.possibleSpawnPoints;
    Lang = item.locales;

    if (item.activateDebug) {
        activateDebug = true;
        console.log("avellon | [INFO] Activated debug mode.");
        console.log("avellon | [INFO] Config: ");
        console.log(`avellon | [INFO] display = ${item.display}`);
        console.log(`avellon | [INFO] activateRegistration = ${item.activateRegistration}`);
        console.log(`avellon | [INFO] possibleLicenses = ${item.possibleLicenses}`);
        console.log(`avellon | [INFO] questionsArray = ${item.questions}`);
        console.log(`avellon | [INFO] possibleSpawnPoints = ${item.possibleSpawnPoints}`);
        console.log(`avellon | [INFO] locales = ${item.locales}`);
    }

    if (item.display && item.activateRegistration) {
        $("#av_dmv_main").removeClass("hidden");
        $("#av_dmv_main").addClass("grid");

        openPage(0);

        if (item.possibleLicenses && item.hasTheoryLicenses && item.hasPracticeLicenses) {
            setupLicenses(item.possibleLicenses, item.hasTheoryLicenses, item.hasPracticeLicenses);
        }
    }
};

window.addEventListener("message", handleMessage);
