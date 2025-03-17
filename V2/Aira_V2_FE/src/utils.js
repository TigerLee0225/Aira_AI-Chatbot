// utils.js
import Swal from 'sweetalert2'

export const showAlert = (title, text, icon = 'info') => {
  Swal.fire({
    title,
    text,
    icon,
    confirmButtonText: '확인'
  })
}
