import XCTest

@testable import Lisw

final class LiswTests: XCTestCase {
  func testTokenize() {
    var actual = tokenize(input: "10")
    XCTAssertEqual(actual, ["10"])

    actual = tokenize(input: "(1 2)")
    XCTAssertEqual(actual, ["(", "1", "2", ")"])
  }

  func testReadFrom() {
    XCTContext.runActivity(named: "number") { _ in
      let (actual, _) = readFrom(tokens: ["20"], startIndex: 0)
      XCTAssertEqual(actual, .Number(20))
    }
  }

  func testParse() {
    XCTContext.runActivity(named: "var") { _ in
      let actual = parse(input: "x")
      XCTAssertEqual(actual, .Symbol("x"))
    }
    XCTContext.runActivity(named: "number") { _ in
      let actual = parse(input: "30")
      XCTAssertEqual(actual, .Number(30))
    }
    XCTContext.runActivity(named: "quote") { _ in
      let actual = parse(input: "(quote 40)")
      XCTAssertEqual(actual, .List([.Symbol("quote"), .Number(40)]))
    }
    XCTContext.runActivity(named: "conditionals") { _ in
      let actual = parse(input: "(if (< 10 20) 1 2)")
      XCTAssertEqual(
        actual,
        .List([
          .Symbol("if"), .List([.Symbol("<"), .Number(10), .Number(20)]), .Number(1), .Number(2),
        ]))
    }
  }

  func testEval() {
    XCTContext.runActivity(named: "symbol") { _ in
      let (actual, _) = eval(sexpr: .Symbol("a"), env: global())
      XCTAssertEqual(actual, nil)
    }
    XCTContext.runActivity(named: "number") { _ in
      let (actual, _) = eval(sexpr: .Number(50), env: global())
      XCTAssertEqual(actual, .Number(50))
    }
    XCTContext.runActivity(named: "quote") { _ in
      let (actual, _) = eval(sexpr: parse(input: "(quote (a b c))"), env: global())
      XCTAssertEqual(actual, .List([.Symbol("a"), .Symbol("b"), .Symbol("c")]))
    }
    XCTContext.runActivity(named: "if") { _ in
      let (actual, _) = eval(sexpr: parse(input: "(if (< 10 20) 1 2)"), env: global())
      XCTAssertEqual(actual, .Number(1))
    }
    XCTContext.runActivity(named: "set!") { _ in
      let (actual, _) = eval(
        sexpr: parse(input: "(begin (define x 70) (set! x 80) x)"), env: global())
      XCTAssertEqual(actual, .Number(80))
    }
    XCTContext.runActivity(named: "define") { _ in
      let (actual, _) = eval(sexpr: parse(input: "(begin (define x 60) x)"), env: global())
      XCTAssertEqual(actual, .Number(60))
    }
    XCTContext.runActivity(named: "lambda") { _ in
      let (actual, _) = eval(
        sexpr: parse(input: "(begin (define inc (lambda (arg) (+ arg 1))) (inc 90))"), env: global()
      )
      XCTAssertEqual(actual, .Number(91))
    }
    XCTContext.runActivity(named: "begin") { _ in
      let (actual, _) = eval(sexpr: parse(input: "(begin 1 2)"), env: global())
      XCTAssertEqual(actual, .Number(2))

    }
    XCTContext.runActivity(named: "procedure calls") { _ in
      let (actual, _) = eval(sexpr: parse(input: "(+ 1 2)"), env: global())
      XCTAssertEqual(actual, .Number(3))
    }

  }
  //    static var allTests = [
  //        ("testExample", testExample),
  //    ]
}
