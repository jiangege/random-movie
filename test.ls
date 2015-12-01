require! {
  "./persistence": {
    random
  }
}
err, docs <~ random {rank: 8}
console.log docs
