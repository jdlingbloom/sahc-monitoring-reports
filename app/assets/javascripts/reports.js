function setupUploader(name, uuidInputName, overrides) {
  var $container = $('#' + name + '_container');
  var $toggle = $('#' + name + '_toggle');
  var $uuids = $('#' + name + '_uuids');

  $toggle.click(function(event) {
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
      onSubmit: function() {
        $('input[type=submit]').attr('disabled', 'disabled');
        $('form').bind('submit', function(e) { e.preventDefault(); });
      },
      onComplete: function(id) {
        if(overrides && overrides.multiple === false) {
          $uuids.empty();
        }

        var uuid = this.getUuid(id);
        $('<input>').attr({
          type: 'hidden',
          name: uuidInputName,
          value: uuid,
        }).appendTo($uuids);
      },
      onAllComplete: function() {
        $('input[type=submit]').removeAttr('disabled', 'disabled');
        $('form').unbind('submit');
      },
      onDelete: function(id) {
        var uuid = this.getUuid(id);
        $uuids.find('[value=' + uuid + ']').remove();
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
