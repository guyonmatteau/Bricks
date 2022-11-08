if (typeof window !== 'undefined') {
  console.log('You are on the browser')
  // ✅ Can use window here
} else {
  console.log('You are on the server')
  console.log(window.ethereum);
}
