swal({title: 'Are you sure?', showCancelButton: true}).then(
  function (result) {
    if (result.value) {
      // handle Confirm button click
      // result.value will contain `true` or the input value
    } else {
      // handle dismissals
      // result.dismiss can be 'cancel', 'overlay', 'esc' or 'timer'
    }
  }
);

