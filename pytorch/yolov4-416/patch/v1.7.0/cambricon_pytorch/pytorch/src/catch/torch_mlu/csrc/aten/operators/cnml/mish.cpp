#include "aten/operators/cnml/cnml_kernel.h"
#include "aten/operators/cnml/internal/cnml_internal.h"

namespace torch_mlu {
namespace cnml {
namespace ops {

at::Tensor cnml_mish(const at::Tensor& input) {
  //return cnml_mish_internal(input);
  auto softplus_out = cnml_softplus_internal(input);
  auto tanh_out = cnml_active_internal(softplus_out, CNML_ACTIVE_TANH);
  auto output = cnml_mul_internal(input, tanh_out);
  return output;
}

}  // namespace ops
}  // namespace cnml
}  // namespace torch_mlu
