import "./CenterTab.css"

import { Routes, Route } from 'react-router-dom';
import Home from "../Home/Home";
import Friends from "../Friends/Friends";
import Profile from "../Profile/Profile";
import Settings from "../Settings/Settings";


function CenterTab() {
    
    return(
		<div class="CenterTab">
			<Routes>
				<Route path="/" element={<Home />} />
				<Route path="/friends" element={<Friends />} />
				<Route path="/profile" element={<Profile />} />
				<Route path="/settings" element={<Settings />} />
			</Routes>
		</div>

    )
}

export default CenterTab;