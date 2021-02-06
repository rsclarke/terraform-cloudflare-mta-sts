addEventListener("fetch", event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const value = await POLICY_NAMESPACE.get("policy")
  if (value === null) {
    return new Response("Policy not found", { status: 404 })
  }

  return new Response(value)
}
