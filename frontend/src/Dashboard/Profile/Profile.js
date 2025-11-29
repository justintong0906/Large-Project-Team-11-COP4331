import "./Profile.css"

import { Routes, Route } from 'react-router-dom';
import ProfileDisplay from "./ProfileDisplay";
import ProfileEdit from "./ProfileEdit";



function Profile() {
    
    return(
		<div>

			<Routes>
				<Route path="/" element={<ProfileDisplay />} />
				<Route path="/edit" element={<ProfileEdit />} />
			</Routes>
		</div>

    )
}

export default Profile;