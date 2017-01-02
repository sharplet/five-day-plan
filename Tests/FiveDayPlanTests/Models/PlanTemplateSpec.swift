@testable import FiveDayPlan
import Quick
import Nimble

final class PlanTemplateSpec: QuickSpec {
  override func spec() {
    let testTemplate = { try PlanTemplate(name: "test", bundle: testBundle) }

    describe("loading") {
      it("loads from a text file") {
        expect { try testTemplate() }.toNot(throwError())
      }

      it("fails to load if the text file doesn't exist") {
        let nonexistent = { try PlanTemplate(name: "nonexistent", bundle: testBundle) }
        expect { try nonexistent() }.to(throwError())
      }
    }

    describe("2017") {
      it("exists") {
        expect(PlanTemplate.year2017).toNot(beNil())
      }
    }
  }
}
