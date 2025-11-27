import { useState } from "react";
import { useSearchParams } from 'react-router-dom';
import "./ResetPassword.css"
const API_BASE = process.env.REACT_APP_API_BASE;

function ResetPassword() {
    const [searchParams] = useSearchParams();
    const paramToken = searchParams.get('token');

    const [message, setMessage] = useState("");
    const [error, setError] = useState("");

    const handleSubmit = async () => {


        const newPassword = document.getElementById("newPassword").value;
        const confirmNewPassword = document.getElementById("confirmNewPassword").value;
        if(newPassword === confirmNewPassword){
            const response = await fetch(`${API_BASE}/auth/reset-password`, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${paramToken}`
                },
                body: JSON.stringify({
                    token: paramToken,
                    password: newPassword
                })
            });
            const data = await response.json();
            if(response.ok){
                setMessage("Password Reset Successfully! Redirecting...");
                setError("");
                setTimeout(() => window.location.href = "/login", 2000);
            }
            else{
                setMessage("");
                setError("Error resetting password.");        
            }
        }
        else{
            setMessage("");
            setError("Passwords do not match");
        }
    }
    
    return(
        <div class="ResetPassword">
            <h1 class="TitleRP">Reset Password</h1>
            <div class="CenterRP">
                <br/>
                <p class="tbLabelRP">New Password</p>
                <input class="textboxRP" placeholder="New Password" id="newPassword" type="password"></input>
                <p class="tbLabelRP">Confirm New Password</p>   
                <input class="textboxRP" placeholder="Confirm New Password" id="confirmNewPassword" type="password"></input>
                {error && <p style={{color:"red"}}>{error}</p>}
                {message && <p style={{color:"green"}}>{message}</p>}
                <button class="CenterRP ButtonSubmitRP" onClick={handleSubmit}>Submit</button>
            </div>
        </div>
    )
}

export default ResetPassword;