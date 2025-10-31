import { useState } from "react";
import SideTab from "./SideTab/SideTab";
import CenterTab from "./CenterTab/CenterTab";
import Footer from "./Footer/Footer";

function Dashboard() {

  const[getVisible, setVisible] = useState(null)

  return (
    <div className="Dashboard">
      <SideTab setVisible={setVisible} />
	  <CenterTab getVisible={getVisible} />
	  <Footer />
    </div>
  );
}

export default Dashboard;