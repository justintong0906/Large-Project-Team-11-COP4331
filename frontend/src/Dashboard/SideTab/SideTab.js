import "./SideTab.css"
import LoginSideTab from "../../Login/LoginSideTab.js"
import logo from "../../images/temp-logo-modified.png"
import { Link } from 'react-router-dom';

function SideTab() {
    
    return(
        <div className="SideTab">
            <Link to="/">
                <img className="Logo NavItem TextButton" src={logo} alt="Logo" />
            </Link>
            <Link to="/" className="NavItem TextButton">Home</Link>
            <Link to="/friends" className="NavItem TextButton">Friends</Link>
            <Link to="/profile" className="NavItem TextButton">Profile</Link>
            <Link to="/settings" className="NavItem TextButton">Settings</Link>
            <Link to="/login" className="NavItem TextButton" style={{marginTop: 'auto'}}>Log Out</Link>
            {/* <LoginSideTab/> */}
        </div>
    )
}

export default SideTab;