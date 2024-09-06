import CableReady from 'cable_ready'
import consumer from './consumer'


consumer.subscriptions.create('BroadcastChannel', {
  // // print out a connection established
  // connected(data) {
  //   console.log("BroadcastChannel" + data)
  // },
  received(data) {
    if (data.cableReady) CableReady.perform(data.operations)

    updateSidebarVisibility()
  }
})


function updateSidebarVisibility() {
  const sidebar = document.getElementById('sidebar');
  // Check if there are any visible children within the sidebar
  const hasVisibleChildren = Array.from(sidebar.children).some(child => {
    return child.offsetWidth > 0 && child.offsetHeight > 0 && !child.classList.contains('hidden');
  });

  if (hasVisibleChildren) {
    // If there are visible children, remove the 'hidden' class if it exists
    sidebar.classList.remove('hidden');
  } else {
    // If no visible children, add the 'hidden' class
    sidebar.classList.add('hidden');
  }
}
