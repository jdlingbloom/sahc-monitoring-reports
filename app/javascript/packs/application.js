import 'font_awesome_icons';
import 'reports';
import 'datatables.net';
import 'datatables.net-bs4';
import Rails from 'rails-ujs';
import $ from 'jquery';

Rails.start();

$(document).ready(function(){
  $('table.table-data-tables').DataTable({
    pageLength: 50,
    order: [[3, 'desc']],
    columnDefs: [
      { targets: 3, type: 'string' },
      { targets: 4, type: 'string' },
      { targets: 5, orderable: false },
    ]
  });
});

