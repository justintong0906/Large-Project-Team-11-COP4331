import "./Friends.css"
import { useState, useEffect } from "react";

// function Friends() {
//     return (
//         <div className="FriendsTab Grid">
//             <div class="GridItem">
//                 <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_lvjjRAVDQ-nBDq_4dy1xCyRjjDaHV-Tqcw&s" class="Image"/>
//                 <h2 class="Name">John Doe</h2>
//             </div>
//             <div class="GridItem">Item 2</div>
//             <div class="GridItem">Item 3</div>
//             <div class="GridItem">Item 4</div>
//             <div class="GridItem">Item 5</div>
//             <div class="GridItem">Item 6</div>
//         </div>			
//     )
// }


function Friends() {
    const [friends, setFriends] = useState([]);

    useEffect(() => {
        const fetchFriends = async () => {
            const token = localStorage.getItem("token");
            const res = await fetch("http://localhost:5001/api/friends", {
                headers: {"Authorization": `Bearer ${token}`}
            });
            const data = await res.json();
            if (res.ok) setFriends(data.friends);
        };
        fetchFriends();
    }, []);

    return (
        <div className="FriendsTab Grid">
            {friends.map(friend => (
                <div class="GridItem" key={friend._id}>
                    <img src={friend.profilePicture} class="Image"/>
                    <h2 class="Name">{friend.username}</h2>
                </div>
            ))}
        </div>			
    )
}


export default Friends;