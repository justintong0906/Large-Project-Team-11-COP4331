import SideTab from "./SideTab/SideTab";
import CenterTab from "./CenterTab/CenterTab";
import Footer from "./Footer/Footer";

function Dashboard() {

  return (
    <div className="Dashboard">
      <SideTab />
      <CenterTab />
      <Footer />
    </div>
  );
}

export default Dashboard;