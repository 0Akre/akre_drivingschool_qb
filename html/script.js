let questions = [];
let currentQuestion = 0;
let answers = [];
let selectedOption = null;
let testPrice = 0;

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        let data = event.data;
        
        if (data.type === 'open') {
            questions = data.questions;
            currentQuestion = 0;
            answers = Array(questions.length).fill(null);
            selectedOption = null;
            testPrice = data.price;
            
            $('#test-price').text(testPrice);
            
            $('#driving-test').removeClass('hidden');
            
            $('#startScreen').removeClass('hidden');
            $('#questionScreen').addClass('hidden');
            $('#resultScreen').addClass('hidden');
            
            createDots();
        }
    });
    
    $('.close-btn').click(function() {
        showConfirmModal();
    });
    
    $('#confirmYes').click(function() {
        $('#confirmModal').addClass('hidden');
        closeUI(false);
    });
    
    $('#confirmNo').click(function() {
        $('#confirmModal').addClass('hidden');
    });
    
    $(document).keyup(function(e) {
        if (e.key === "Escape" && !$('#driving-test').hasClass('hidden')) {
            showConfirmModal();
        }
    });
    
    $('#start-btn').click(function() {
        $.post('https://akre_drivingschool_qb/startTest', JSON.stringify({}), function(response) {
            if (response.success) {
                $('#startScreen').addClass('hidden');
                $('#questionScreen').removeClass('hidden');
                updateQuestionDisplay();
            } else {
                closeUI(false);
            }
        });
    });
    
    $(document).on('click', '.option', function() {
        $('.option').removeClass('selected');
        $(this).addClass('selected');
        selectedOption = $(this).data('value');
        answers[currentQuestion] = selectedOption;
        
        $(`.pagination-dot:eq(${currentQuestion})`).addClass('answered');
        
        updateFinishButtonState();
    });
    
    $('#next-btn').click(function() {
        if ($(this).hasClass('disabled')) {
            return;
        }
        
        if (currentQuestion === questions.length - 1) {
            if (areAllQuestionsAnswered()) {
                showResults();
            }
        } else {
            currentQuestion++;
            updateQuestionDisplay();
        }
    });
    
    $('#prev-btn').click(function() {
        if (currentQuestion > 0) {
            currentQuestion--;
            updateQuestionDisplay();
        }
    });
    
    $(document).on('click', '.pagination-dot', function() {
        let index = $(this).index();
        currentQuestion = index;
        updateQuestionDisplay();
    });
    
    $(document).on('click', '#incompleteClose', function() {
        $('#incompleteModal').addClass('hidden');
    });
});

function showConfirmModal() {
    $('#confirmModal').removeClass('hidden');
}

function createDots() {
    let dotsHtml = '';
    for (let i = 0; i < questions.length; i++) {
        dotsHtml += `<div class="pagination-dot ${i === 0 ? 'active' : ''}"></div>`;
    }
    $('#dots-container').html(dotsHtml);
}

function updateQuestionDisplay() {
    $('#question-text').text(questions[currentQuestion].question);
    
    let optionsHtml = '';
    questions[currentQuestion].options.forEach(option => {
        let selected = answers[currentQuestion] === option ? 'selected' : '';
        optionsHtml += `
            <div class="option ${selected}" data-value="${option}">
                <span class="dot"></span>
                ${option}
            </div>`;
    });
    $('#options-container').html(optionsHtml);
    
    $('#prev-btn').prop('disabled', currentQuestion === 0);
    
    if (currentQuestion === questions.length - 1) {
        $('#next-btn').html('<i class="fas fa-rocket btn-icon"></i><span>Finish</span>');
    } else {
        $('#next-btn').html('<span>Next</span><i class="fas fa-chevron-right"></i>');
    }
    
    $('#prev-btn').html('<i class="fas fa-chevron-left"></i><span>Back</span>');
    
    $('.pagination-dot').removeClass('active');
    $(`.pagination-dot:eq(${currentQuestion})`).addClass('active');
    
    for (let i = 0; i < answers.length; i++) {
        if (answers[i] !== null) {
            $(`.pagination-dot:eq(${i})`).addClass('answered');
        }
    }
    
    selectedOption = answers[currentQuestion];
    
    updateFinishButtonState();
}

function updateFinishButtonState() {
    if (currentQuestion === questions.length - 1) {
        if (areAllQuestionsAnswered()) {
            $('#next-btn').removeClass('disabled');
            $('#next-btn').css('opacity', '1');
            $('#next-btn').css('cursor', 'pointer');
        } else {
            $('#next-btn').addClass('disabled');
            $('#next-btn').css('opacity', '0.5');
            $('#next-btn').css('cursor', 'not-allowed');
        }
    } else {
        $('#next-btn').removeClass('disabled');
        $('#next-btn').css('opacity', '1');
        $('#next-btn').css('cursor', 'pointer');
    }
}

function areAllQuestionsAnswered() {
    return !answers.includes(null);
}

function showResults() {
    let correctAnswers = 0;
    
    for (let i = 0; i < questions.length; i++) {
        if (answers[i] === questions[i].correct) {
            correctAnswers++;
        }
    }
    
    let percentage = (correctAnswers / questions.length) * 100;
    let passed = percentage >= 70;
    
    $('#questionScreen').addClass('hidden');
    $('#resultScreen').removeClass('hidden');
    
    if (passed) {
        $('#result-title').text('Test passed!').addClass('pass').removeClass('fail');
        $('#result-message').text('Congratulations! You have successfully passed the theoretical exam.');
    } else {
        $('#result-title').text('Test failed').addClass('fail').removeClass('pass');
        $('#result-message').text('Im afraid you didnt pass the theory test. Please try again.');
    }
    
    $('#score-display').text(`${percentage.toFixed(0)}%`);
    
    setTimeout(function() {
        closeUI(true);
    }, 3000);
}

function closeUI(completed) {
    $('#driving-test').addClass('hidden');
    $('#confirmModal').addClass('hidden');
    if ($('#incompleteModal').length > 0) {
        $('#incompleteModal').addClass('hidden');
    }
    
    questions = [];
    currentQuestion = 0;
    answers = [];
    selectedOption = null;
    
    if (completed) {
        $.post('https://akre_drivingschool_qb/completeTest', JSON.stringify({
            passed: $('#result-title').hasClass('pass'),
            score: parseFloat($('#score-display').text())
        }));
    } else {
        $.post('https://akre_drivingschool_qb/close', JSON.stringify({}));
    }
}