// Global variables

var container;
var form;
var display;
var validKeys;
var invalidKeys;
var backspace;
var one;
var two;
var three;
var four;
var five;
var six;
var seven;
var eight;
var nine;
var interval;
var code;

// jQuery

$(document).ready(function(){
  
  container = $('#container');
  form = $('form');
  display = $('#display');
  
  validKeys = [ 48,49,50,51,52,53,54,55,56,57,
                    96,97,98,99,100,101,102,103,104,105 ];
                    
  invalidKeys = [ 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,
                      0,32,61,107,108,109,110,111,186,187,188,189,190,191,192,219,220,221,222 ];
  
  backspace = 8;
  one   = [49,97];
  two   = [50,98];
  three = [51,99];
  four  = [52,100];
  five  = [53,101];
  six   = [54,102];
  seven = [55,103];
  eight = [56,104];
  nine  = [57,105];
  
  // Map clicking on the keys to showing the number in the display
  $('a').click(function(e){
    e.preventDefault();
    if ($('.clone').length < 5) {
      var num = $(this).attr('class').split(' ')[0];
      displayNum(num);
    }
  });
  
  // Disable the backspace key
  $(document).keydown(function(e) {
    if (e.which === backspace) { return false; }
  });
  
  // Map keyboard number keys to showing the number in the display
  $(document).keyup(function(e){
    if (e.which === backspace && $('.clone').length > 0) {
      $('.clone').last().remove();
    } else if (validKeys.indexOf(e.which) >= 0 && $('.clone').length < 5) {
      var n = e.which;
      var num = '';
      if (one.indexOf(n) >= 0)        { num = 'one' }
      else if (two.indexOf(n) >= 0)   { num = 'two' }
      else if (three.indexOf(n) >= 0) { num = 'three' }
      else if (four.indexOf(n) >= 0)  { num = 'four' }
      else if (five.indexOf(n) >= 0)  { num = 'five' }
      else if (six.indexOf(n) >= 0)   { num = 'six' }
      else if (seven.indexOf(n) >= 0) { num = 'seven' }
      else if (eight.indexOf(n) >= 0) { num = 'eight' }
      else if (nine.indexOf(n) >= 0)  { num = 'nine' }
      if (num !== '') {
        displayNum(num);
      }
    }
  });
  
  observeKeypad();
  
});  

// Global functions

function displayNum(num) {
  if (!container.hasClass('success') && !container.hasClass('failure')) {
    var led = $('#display .' + num + ':not(.clone)');
    led.clone().addClass('clone').appendTo(display).show();
  }
}

function observeKeypad() {
  interval = setInterval("checkCode()", 250);
}

function stopObserving() {
  clearInterval(interval);
}

function checkCode() {
  // Check that the code is 5 digits long, and check it via ajax
  if ($('.clone').length == 5) {
    stopObserving();
    code = '';
    $('.clone').each(function(){
      code += $(this).attr('rel');
    });
    ajax();
  }
}

function ajax() {
  $.ajax({
    type: "POST",
    url: "/",
    data: "code=" + code,
    dataType: "text",
    success: function(data, textStatus, jqXHR){
      if (data === 'Success') { showSuccess(); } else
      if (data === 'Failure') { showError(); }
    }
  });
}

function showSuccess() {
  // Go blue, show SUCCESS
  $('.clone').remove();
  container.addClass('success');
  setTimeout('window.location.reload()', 1000);
}

function showError() {
  // Go red, show ERROR
  $('.clone').remove();
  container.addClass('failure');
  setTimeout('reset()', 1000);
}

function reset() {
  // Go green, clear display, restart interval
  container.removeClass('failure');
  observeKeypad();
}