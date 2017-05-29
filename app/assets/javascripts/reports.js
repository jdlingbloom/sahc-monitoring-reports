function setupUploader(name, uuidInputName, overrides) {
  var $container = $('#' + name + '_container');
  var $toggle = $('#' + name + '_toggle');
  var $uuids = $('#' + name + '_uuids');

  $toggle.find('a').click(function(event) {
    $container.show();
    $toggle.hide();
    event.preventDefault();
  });

  var options = {
    element: document.getElementById(name),
    template: 'qq-simple-thumbnails-template',
    request: {
      endpoint: '/uploads',
      uuidName: 'uuid',
      inputName: 'file',
      customHeaders: {
        'X-CSRF-Token': $.rails.csrfToken(),
      },
    },
    deleteFile: {
      enabled: true,
      endpoint: '/uploads',
      customHeaders: {
        'X-CSRF-Token': $.rails.csrfToken(),
      },
    },
    validation: {
      allowedExtensions: ['jpg', 'jpeg', 'kmz'],
    },
    callbacks: {
      onStatusChange: function() {
        var uploads = this.getUploads();
        var uuids = [];
        for(var i = 0; i < uploads.length; i++) {
          var upload = uploads[i];
          if(upload.status === qq.status.UPLOAD_SUCCESSFUL) {
            uuids.push(upload.uuid);
          } else if(upload.status !== qq.status.CANCELED && upload.status !== qq.status.REJECTED && upload.status !== qq.status.DELETED) {
            $('button[type=submit]').attr('disabled', 'disabled');
            $('form').bind('submit', function(e) { e.preventDefault(); });
            return;
          }
        }

        $uuids.empty();
        for(var i = 0; i < uuids.length; i++) {
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

  var existingUuids = $uuids.find('input').map(function() { return $(this).val(); }).get();
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
