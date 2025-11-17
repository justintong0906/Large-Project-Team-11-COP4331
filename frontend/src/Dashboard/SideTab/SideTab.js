import "./SideTab.css"
import LoginSideTab from "../../Login/LoginSideTab.js"
import logo from "../../images/temp-logo-modified.png"
import { Link } from 'react-router-dom';

function SideTab() {
    const handleLogout = (e) => {
        localStorage.removeItem("token");
        window.location.href = "/login";
    };
    
    return(
        <div className="SideTab">
            <Link to="/">
                <img className="Logo NavItem TextButton" src={logo} alt="Logo" />
            </Link>
            <Link to="/" className="NavItem TextButton">Home</Link>
            <Link to="/friends" className="NavItem TextButton">Friends</Link>
            <Link to="/profile" className="NavItem TextButton">Profile</Link>
            <a href="#" onClick={handleLogout} className="NavItem TextButton" style={{marginTop: 'auto'}}>Log Out</a>
            {/* <LoginSideTab/> */}
        </div>
    )
}

export default SideTab;