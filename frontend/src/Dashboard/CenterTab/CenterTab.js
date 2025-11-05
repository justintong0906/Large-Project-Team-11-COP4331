import "./CenterTab.css"

import { Routes, Route } from 'react-router-dom';
import Home from "../Home/Home";
import Friends from "../Friends/Friends";
import Profile from "../Profile/Profile";


function CenterTab() {
    
    return(
		<div class="CenterTab">
			<Routes>
				<Route path="/" element={<Home />} />
				<Route path="/friends" element={<Friends />} />
				<Route path="/profile" element={<Profile />} />
			</Routes>
		</div>

    )
}

export default CenterTab;