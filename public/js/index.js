$(document).ready(function() {
  addCode().find('input').focus();
  $('.send').click(function(event) {
    var form = $(event.target).parents('form');
    form.find('input').removeAttr('disabled');
    return true;
  });
  // TODO: sinatra-minify
  // TODO: get modal working
});

function template(type) {
  var html = $('#'+type).clone();
  html.removeClass('template');
  html.attr('id', null);
  return html;
}

var codeNum = 0;

function addCode() {
  var id = 'code' + codeNum;
  var name = 'code[' + codeNum + ']';
  codeNum++;
  var html = template('code');
  var button = html.find('button');
  var input = html.find('input');
  html.attr('id', id);
  html.addClass('code');
  html.find('i').attr('class','icon-question-sign');
  input.attr('name',name).keypress(function(event) {
    if(event.which && event.which == 13) {
      button.click();
      return false;
    }
  });
  button.addClass('btn-primary').click(function(event) {
    if(getCode(id) == "")
      return false;
    if(!validateCode(id))
      return false;
    addCode().find('input').focus();
    var button = $(event.target);
    button.off('click');
    return false;
  });
  $('#codes').prepend(html);
  return html;
}

function getCodeStatus(code) {
  var status;
  $.ajax({url: "/code/"+code, async: false}).done(function(data) {
    status = eval('('+data+')');
  });
  if(status)
    return status;
  else
    return {success: false};
}

function getCode(id) {
  return $('#'+id).find('input')[0].value;
}

function validateCode(id) {
  var html = $('#'+id);
  var code = getCode(id);
  // TODO: ajax animation while waiting
  // TODO: check for duplicate codes
  var status = getCodeStatus(code);
  if(status == null) {
    alert('undefined');
    return false;
  }
  html.find('button').removeClass('btn-success btn-danger');
  html.find('.control-group').removeClass('success error');
  html.find('input').attr('placeholder',null);
  if(status.success) {
    // success
    html.find('i').attr('class','icon-ok');
    html.find('button').addClass('btn-success');
    html.find('.control-group').addClass('success');
    // disable
    html.find('input').attr('disabled','disabled');
    html.find('button').attr('disabled','disabled');
    // add BTC amount
    html.find('input').attr('id','appendedPrependedInputButton');
    html.find('.input-append').addClass('input-prepend');
    html.find('.amount').removeClass('hidden').html(status.amount + '\u0e3f');
    return true;
  } else {
    // failure
    html.find('i').attr('class','icon-remove');
    html.find('button').addClass('btn-danger');
    html.find('.control-group').addClass('error');
    return false;
  }
}
