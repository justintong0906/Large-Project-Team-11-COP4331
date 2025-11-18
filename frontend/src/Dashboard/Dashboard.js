import "./Dashboard.css";
import SideTab from "./SideTab/SideTab";
import CenterTab from "./CenterTab/CenterTab";
import Footer from "./Footer/Footer";
import { useNavigate } from "react-router-dom"
import { useEffect } from "react"

const API_BASE = process.env.REACT_APP_API_BASE;


function Dashboard() {
  //send user back to login if not logged in
  const navigate = useNavigate();
  useEffect(() => {
      const token = localStorage.getItem("token");
      if (!token) {
          navigate("/login");
      }
  }, [navigate]);

  //send user to quiz if they havent completed it
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
        fetch(`${API_BASE}/users/me`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            }
        })
        .then(response => response.json())
        .then(data => {
            if (!data.gender) { // if gender doesn't exist, they never completed their quiz
                navigate("/quiz");
            }
        })
        .catch(error => {
            console.error("Error fetching quiz status:", error);
        });
    }
  }, [navigate]);


  return (
    <div>
      <SideTab />
      <CenterTab />
      {/* <Footer /> */}
    </div>
  );
}

export default Dashboard;