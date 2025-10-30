import LoginSideTab from "./LoginSideTab"
import { ShowBox } from "./LoginBox";
import "./Login.css"
import LoginLogo from "./LoginLogo";

function Login() {
    return(
        <div class="Login">
            <LoginLogo/>
            <ShowBox/>
        </div>
    )
}

export default Login;