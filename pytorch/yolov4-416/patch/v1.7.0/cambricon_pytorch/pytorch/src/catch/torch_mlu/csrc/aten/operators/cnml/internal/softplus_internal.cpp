#include "aten/operators/cnml/internal/cnml_internal.h"

namespace torch_mlu {
namespace cnml {
namespace ops {
at::Tensor cnml_softplus_internal(const at::Tensor& input) {
  auto output = at::native::empty_like(input);
  // prepare input cnml tensor
  auto* input_impl = getMluTensorImpl(input);
  auto input_cnml_tensor = input_impl->CreateCnmlTensor(CNML_TENSOR, toCnmlDataType(input.dtype()));
  // prepare output cnml tensor
  auto* output_impl = getMluTensorImpl(output);
  auto output_cnml_tensor = output_impl->CreateCnmlTensor(CNML_TENSOR, toCnmlDataType(output.dtype()));
  // End the execution flow if not MLU device
  CHECK_MLU_DEVICE(output);

  // setup operator
  cnmlBaseOp_t softplus_op;
  TORCH_CNML_CHECK(cnmlCreateSoftplusOp(&softplus_op,
                                        input_cnml_tensor,
                                        output_cnml_tensor));

  // return to JIT if running mode is fuse
  CHECK_RETURN_TO_FUSE(softplus_op, output);

  // compile op
  TORCH_CNML_CHECK(cnmlCompileBaseOp(softplus_op, GET_CORE_VERSION, GET_CORE_NUMBER));

  // compute operator
  auto queue = getCurQueue();
  TORCH_CNML_CHECK(cnmlComputeSoftplusOpForward_V4(softplus_op,
                                                   NULL,
                                                   input_impl->raw_mutable_data(),
                                                   NULL,
                                                   output_impl->raw_mutable_data(),
                                                   queue,
                                                   NULL));

  syncQueue(queue);
  // destroy params and ops
  TORCH_CNML_CHECK(cnmlDestroyBaseOp(&softplus_op));
  return output;
}

}  // namespace ops
}  // namespace cnml
}  // namespace torch_mlu

