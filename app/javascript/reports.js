import 'jquery.dirtyforms';
import $ from 'jquery';
import qq from 'fine-uploader'
import Rails from 'rails-ujs';

window.setupUploader = function setupUploader(name, uuidInputName, overrides) {
  const $container = $('#' + name + '_container');
  const $toggle = $('#' + name + '_toggle');
  const $uuids = $('#' + name + '_uuids');

  $toggle.find('a').click(function(event) {
    $container.show();
    $toggle.hide();
    event.preventDefault();
  });

  const options = {
    element: document.getElementById(name),
    template: 'qq-simple-thumbnails-template',
    request: {
      endpoint: '/uploads',
      uuidName: 'uuid',
      inputName: 'file',
      customHeaders: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    },
    deleteFile: {
      enabled: true,
      endpoint: '/uploads',
      customHeaders: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    },
    validation: {
      allowedExtensions: ['jpg', 'jpeg', 'kmz'],
    },
    callbacks: {
      onStatusChange: function() {
        const uploads = this.getUploads();
        const uuids = [];
        for(let i = 0; i < uploads.length; i++) {
          const upload = uploads[i];
          if(upload.status === qq.status.UPLOAD_SUCCESSFUL) {
            uuids.push(upload.uuid);
          } else if(upload.status !== qq.status.CANCELED && upload.status !== qq.status.REJECTED && upload.status !== qq.status.DELETED) {
            $('button[type=submit]').attr('disabled', 'disabled');
            $('form').bind('submit', function(e) { e.preventDefault(); });
            return;
          }
        }

        $uuids.empty();
        for(let i = 0; i < uuids.length; i++) {
          $('<input>').attr({
            type: 'hidden',
            name: uuidInputName,
            value: uuids[i],
          }).appendTo($uuids);
        }

        $('button[type=submit]').removeAttr('disabled', 'disabled');
        $('form').unbind('submit');
      },
    },
  };

  const existingUuids = $uuids.find('input').map(function() { return $(this).val(); }).get();
  if(existingUuids.length > 0) {
    $container.show();
    $.extend(options, {
      session: {
        endpoint: '/uploads',
        params: {
          uuids: existingUuids.join(','),
        },
      },
    });
  }

  if(overrides) {
    $.extend(options, overrides);
  }

  new qq.FineUploader(options);
}

window.pollReport = function(reportId) {
  let redirected = false;
  $.ajax({
    url: `/reports/${reportId}.json`,
  }).done(function(data) {
    if(data && data.upload_progress !== 'pending') {
      let params = '';
      if(data.upload_progress === null) {
        params = '?new_uploads=true';
      }
      redirected = true;
      window.location.href = window.location.href + params;
    }
  }).always(function() {
    if(!redirected) {
      setTimeout(window.pollReport, 500, reportId);
    }
  });
}

$(document).ready(function() {
  $('form.report-form').dirtyForms();

  $(document).on('submit', 'form.report-form', function() {
    const $form = $(this);
    $form.find(':submit').each(function() {
      const $button = $(this);
      const label = $button.data('after-submit-text');
      if(label) {
        $button.html(label).prop('disabled', true);
      }
    });
  });

  const $arrayContainer = $('.report-form .form-group.array .array-inputs-container')
  function appendArrayElement() {
    if($arrayContainer.find('input:last-child').val() !== '') {
      const $newElement = $('.form-group.array input:last-child').clone();
      $newElement.val('');
      $arrayContainer.append($newElement);
    }
  }
  appendArrayElement();
  $arrayContainer.on('keyup', 'input', appendArrayElement);
});
