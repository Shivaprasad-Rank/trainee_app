// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .
function update_guest_status(status, id){
    $.ajax({
        type: 'put',
        url: "/students/"+id+"/update_status",
        data: "status="+status,
        success: function(html){
            $("#status_"+id).html(html);
        }
    })
}

function send_student_mail(email ,id){
$.ajax({
        type: 'get',
        url: "/students/"+id+"/send_mail",
        data: "email="+email,
        success: function(html){
            $("#email_"+id).html(html);
        }
    })
}
