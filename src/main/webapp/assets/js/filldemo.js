function fillDemo(email, password) {
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');

    if (emailInput && passwordInput) {
        emailInput.value = email;
        passwordInput.value = password;
    } else {
        console.error("Không tìm thấy phần tử email hoặc password trên giao diện.");
    }
}