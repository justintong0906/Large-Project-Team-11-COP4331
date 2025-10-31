import "./SideTab.css"
import LoginSideTab from "../../Login/LoginSideTab.js"
import logo from "../../images/temp-logo-modified.png"

function SideTab({ setVisible }) {
    
    return(
        <div className="SideTab">
            <a href="/">
                <img className="Logo NavItem TextButton" src={logo} alt="Logo" />
            </a>
            <button className="NavItem TextButton" onClick={() => setVisible(0)}>Home</button>
            <button className="NavItem TextButton" onClick={() => setVisible(1)}>Friends</button>
            <button className="NavItem TextButton" onClick={() => setVisible(2)}>Profile</button>
            <button className="NavItem TextButton" onClick={() => setVisible(3)}>Settings</button>
            <a className="NavItem TextButton" href="/login" style={{marginTop: 'auto'}}>Log Out</a>
            {/* <LoginSideTab/> */}
        </div>
    )
}

export default SideTab;