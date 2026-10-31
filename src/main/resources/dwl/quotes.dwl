%dw 2.0
output application/json
---
[
  {
    quoteId: "q-100",
    customerName: "Acme Corp",
    amount: 1200.00,
    currency: "USD",
    status: "open"
  },
  {
    quoteId: "q-200",
    customerName: "Northwind Traders",
    amount: 480.50,
    currency: "USD",
    status: "accepted"
  }
]
