async function login() {

    // Ambil nilai email dan password dari form
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value;

    // Validasi sederhana
    if (email === "" || password === "") {
        alert("Email dan Password wajib diisi!");
        return;
    }

    try {

        // Kirim data ke Google Apps Script
        const result = await postAPI({
            action: "login",
            email: email,
            password: password
        });

        console.log(result);

        if (result.success) {

            // Simpan token dan data user
            localStorage.setItem("token", result.data.token);
            localStorage.setItem("nama", result.data.user.nama);
            localStorage.setItem("email", result.data.user.email);

            alert("Login Berhasil");

            // Pindah ke dashboard
            window.location.href = "pages/dashboard.html";

        } else {

            alert(result.message);

        }

    } catch (error) {

        console.error(error);
        alert("Tidak dapat terhubung ke server.");

    }

}
