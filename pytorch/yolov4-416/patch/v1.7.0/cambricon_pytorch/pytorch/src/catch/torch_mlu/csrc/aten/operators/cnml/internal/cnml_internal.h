#pragma once

#include "aten/core/tensor_impl.h"
#include "aten/core/tensor_util.h"
#include "aten/device/exceptions.h"
#include "aten/device/queue.h"
#include "aten/util/cnlog.h"
#include "aten/util/common.h"
#include "aten/util/memory_allocator.h"

namespace torch_mlu {
namespace cnml {
namespace ops {

// infer mlu NHWC dims according to cpu NCHW
static inline void infer_mlu_dims(const std::vector<int64_t>& cpu_dims,
                                  std::vector<int64_t>& mlu_dims) {
  TORCH_CHECK(cpu_dims.size() == mlu_dims.size(),
              "CPU and MLU should be same size.  CPU size: ", cpu_dims.size(),
              "MLU size: ", mlu_dims.size());
  mlu_dims[0] = cpu_dims[0];
  mlu_dims.back() = cpu_dims[1];
  for (size_t i = 1; i < cpu_dims.size() - 1; ++i) {
    mlu_dims[i] = cpu_dims[i + 1];
  }
}

at::Tensor cnml_abs_internal(const at::Tensor& input);

at::Tensor cnml_active_internal(const at::Tensor& input,
                                cnmlActiveFunction_t active_func);

at::Tensor cnml_addpad_internal(const at::Tensor& input, at::IntArrayRef pad,
                                float value);

at::Tensor cnml_transpose_internal(const at::Tensor& input, int dim_order[],
                                   int64_t odim);

at::Tensor cnml_mean_internal(const at::Tensor& input, int64_t dim);

at::Tensor cnml_sum_internal(const at::Tensor& input, int64_t dim);

at::Tensor cnml_std_internal(const at::Tensor& input, int64_t dim,
                             bool unbiased);

at::Tensor cnml_mse_loss_internal(const at::Tensor& self,
                                  const at::Tensor& target, int64_t reduction);

at::Tensor cnml_reciprocal_internal(const at::Tensor& input);

at::Tensor cnml_conv_depthwise2d_internal(const at::Tensor& input_t,
                                          const at::Tensor& weight_t,
                                          const at::Tensor& bias_t,
                                          torch::List<int64_t> padding,
                                          torch::List<int64_t> stride,
                                          torch::List<int64_t> dilation);

at::Tensor cnml_generic_conv_internal(
    const at::Tensor& input, const at::Tensor& weight, const at::Tensor& bias,
    torch::List<int64_t> padding, torch::List<int64_t> stride,
    torch::List<int64_t> dilation, int64_t groups, std::vector<float> q_scale,
    int q_mode);

// cnplugin conv3d
at::Tensor cnml_conv3d_internal(const at::Tensor& input,
                                const at::Tensor& weight,
                                const at::Tensor& bias,
                                torch::List<int64_t> padding,
                                torch::List<int64_t> stride,
                                torch::List<int64_t> dilation,
                                int64_t groups,
                                std::vector<float> q_scale,
                                int q_mode);

at::Tensor cnml_first_conv_internal(
    const at::Tensor& input, const at::Tensor& weight, const at::Tensor& bias,
    torch::List<int64_t> padding, torch::List<int64_t> stride,
    torch::List<int64_t> dilation, int64_t groups, std::vector<float> q_scale,
    int q_mode, std::vector<float> mean, std::vector<float> std);

at::Tensor cnml_convtranspose2d_internal(
    const at::Tensor& input, const at::Tensor& weight, const at::Tensor& bias,
    torch::List<int64_t> stride, torch::List<int64_t> padding,
    torch::List<int64_t> output_padding, int64_t groups,
    torch::List<int64_t> dilation, std::vector<float> q_scale, int q_mode,
    float output_padding_value);

at::Tensor cnml_convtranspose2d_depthwise_internal(
    const at::Tensor& input, const at::Tensor& weight, const at::Tensor& bias,
    torch::List<int64_t> stride, torch::List<int64_t> padding,
    torch::List<int64_t> output_padding, int64_t groups,
    torch::List<int64_t> dilation,
    float output_padding_value);

at::Tensor cnml_convtranspose3d_internal(const at::Tensor& input,
                                         const at::Tensor& weight,
                                         const at::Tensor& bias,
                                         torch::List<int64_t> stride,
                                         torch::List<int64_t> padding,
                                         torch::List<int64_t> output_padding,
                                         int64_t groups,
                                         torch::List<int64_t> dilation,
                                         std::vector<float> q_scale,
                                         int q_mode);

at::Tensor cnml_linear_internal(const at::Tensor& input,
                                const at::Tensor& weight,
                                const at::Tensor& bias,
                                std::vector<float> q_scale, int q_mode);

at::Tensor cnml_lrn_internal(const at::Tensor& input, int64_t size,
                             double alpha, double beta, double k,
                             const std::vector<float>& q_scale, int q_mode);

at::Tensor cnml_nearestneighbor_internal(const at::Tensor& self,
                                         at::IntArrayRef output_size);

at::Tensor cnml_interp_internal(const at::Tensor& self,
                                at::IntArrayRef output_size,
                                bool align_corners);

at::Tensor cnml_reshape_internal(const at::Tensor& input, int data_order[],
                                 int data_order_size);

at::Tensor cnml_reshape_for_rnn_internal(const at::Tensor& input, int dim_order[],
                                 int order_size, float scale, int qmode);

at::Tensor cnml_pow_internal(const at::Tensor& input, at::Scalar exponent);

at::Tensor cnml_maximum_internal(const at::Tensor& input,
                                 const at::Tensor& other);

at::Tensor cnml_minimum_internal(const at::Tensor& input,
                                 const at::Tensor& other);

std::tuple<at::Tensor, at::Tensor> cnml_max_internal(const at::Tensor& input);

at::Tensor cnml_dyadic_internal(const at::Tensor& input1,
                                const at::Tensor& input2,
                                std::vector<int64_t> broadcast_size,
                                int mode);

at::Tensor cnml_mult_internal(const at::Tensor& self, const at::Tensor& other);

std::tuple<at::Tensor, at::Tensor> cnml_topk_internal(const at::Tensor& input,
                                                      const int dim,
                                                      const bool keepdim,
                                                      const int k,
                                                      const bool largest);

at::Tensor cnml_pool1d_internal(const at::Tensor& input,
                                at::IntArrayRef kernel_size,
                                at::IntArrayRef stride, at::IntArrayRef padding,
                                at::IntArrayRef dilation, int64_t pool_mode_row,
                                bool ceil_mode, bool count_include_pad);

std::tuple<at::Tensor, at::Tensor> big_topk_internal(const at::Tensor& input,
                                                     const int dim,
                                                     const bool keepdim,
                                                     const int k,
                                                     const bool largest);

at::Tensor cnml_pool2d_internal(const at::Tensor& input,
                                at::IntArrayRef kernel_size,
                                at::IntArrayRef stride, at::IntArrayRef padding,
                                at::IntArrayRef dilation, int64_t pool_mode_row,
                                bool ceil_mode, bool count_include_pad,
                                c10::optional<int64_t> divisor_override);

at::Tensor cnml_pool3d_internal(const at::Tensor& input,
                                at::IntArrayRef kernel_size,
                                at::IntArrayRef stride, at::IntArrayRef padding,
                                at::IntArrayRef dilation, int64_t pool_mode_row,
                                bool ceil_mode, bool count_include_pad,
                                c10::optional<int64_t> divisor_override);

std::tuple<at::Tensor, at::Tensor> cnml_pool2d_index_internal(
    const at::Tensor& input, at::IntArrayRef kernel_size,
    at::IntArrayRef stride, at::IntArrayRef padding, at::IntArrayRef dilation,
    bool ceil_mode, bool count_include_pad);

at::Tensor cnml_max_unpool2d_internal(const at::Tensor & self,
                                      const at::Tensor & indices,
                                      torch::List<int64_t> kernel_size,
                                      torch::List<int64_t> stride,
                                      torch::List<int64_t> padding,
                                      torch::List<int64_t> output_size);

at::Tensor cnml_sqrt_internal(const at::Tensor& input);

at::Tensor cnml_sign_internal(const at::Tensor& input);

at::Tensor cnml_tril_internal(const at::Tensor& input, int64_t diagonal);

at::Tensor cnml_le_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_log_internal(const at::Tensor& input);

at::Tensor cnml_log_softmax_internal(const at::Tensor& input, int64_t dim,
                                     bool half_to_float, at::Tensor& output);

at::Tensor cnml_rsqrt_internal(const at::Tensor& self);

at::Tensor cnml_concat_internal(at::TensorList tensors, int64_t dim);

at::Tensor cnml_slice_internal(const at::Tensor& input, int64_t dim,
                               int64_t start, int64_t end, int64_t step);

at::Tensor cnml_add_internal(const at::Tensor& input1,
                             const at::Tensor& input2);

at::Tensor cnml_add_internal(const at::Tensor& self, at::Scalar other);

at::Tensor cnml_scale_internal(const at::Tensor& input,
                               const at::Tensor& weight,
                               const at::Tensor& bias);

at::Tensor cnml_broadcast_internal(const at::Tensor& self,
                                   std::vector<int64_t> output_dims);

std::vector<at::Tensor> cnml_split_internal(const at::Tensor& input,
                                            const int64_t split_size,
                                            const int64_t dim);

at::Tensor cnml_normalize_internal(const at::Tensor& input,
                                   const int64_t p,
                                   const at::Tensor& scale,
                                   const double eps);

at::Tensor cnml_prelu_internal(const at::Tensor& self,
                               const at::Tensor& weight);

at::Tensor cnml_softmax_internal(const at::Tensor& self, int64_t dim_);

at::Tensor cnml_clamp_internal(const at::Tensor& input,
                               at::optional<at::Scalar> min,
                               at::optional<at::Scalar> max);

at::Tensor cnml_leaky_relu_internal(const at::Tensor& input,
                                    at::Scalar alpha_t);

at::Tensor cnml_elu_internal(const at::Tensor& input, at::Scalar alpha);

at::Tensor cnml_mish_internal(const at::Tensor& self);

at::Tensor cnml_softplus_internal(const at::Tensor& self);

at::Tensor cnml_embedding_internal(const at::Tensor& weight,
                                   const at::Tensor& indices);

at::Tensor cnml_less_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_batch_norm_internal(const at::Tensor& input,
                                    const at::Tensor& running_mean,
                                    const at::Tensor& running_var, double eps);

at::Tensor cnml_instance_norm_internal(const at::Tensor& input,
                                       double eps);

at::Tensor cnml_thrs_internal(const at::Tensor& input, at::Scalar threshold);

at::Tensor cnml_realdiv_internal(const at::Tensor&, const at::Tensor&);

at::Tensor cnml_eq_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_eq_internal(const at::Tensor& self, at::Scalar other);

at::Tensor cnml_exp_internal(const at::Tensor& self);

at::Tensor cnml_erf_internal(const at::Tensor& self);

at::Tensor cnml_floor_internal(const at::Tensor& self);

at::Tensor cnml_frozen_batch_norm_internal(const at::Tensor& input,
                                           const at::Tensor& weight,
                                           const at::Tensor& bias,
                                           const at::Tensor& running_mean,
                                           const at::Tensor& running_var);

at::Tensor cnml_cos_internal(const at::Tensor& input);

at::Tensor cnml_sin_internal(const at::Tensor& input);

at::Tensor cnml_ne_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_and_internal(const at::Tensor& input, const at::Tensor& other);

at::Tensor cnml_iand_internal(at::Tensor& input, const at::Tensor& other);

at::Tensor cnml_gt_internal(const at::Tensor& input, const at::Tensor& other);

at::Tensor cnml_or_internal(const at::Tensor& input, const at::Tensor& other);

at::Tensor cnml_yolov3_detection_output_internal(
    const at::Tensor& alpha_data, const at::Tensor& beta_data,
    const at::Tensor& gamma_data, torch::List<int64_t> anchor_data,
    int64_t num_classes, int64_t num_anchors, int64_t img_size,
    double conf_thres, double nms_thres, int64_t maxBoxNum);

at::Tensor cnml_yolov5_detection_output_internal(const at::Tensor& alpha_data,
    const at::Tensor& beta_data, const at::Tensor& gamma_data, 
    torch::List<int64_t> anchor_data, int64_t num_classes,
    int64_t num_anchors, int64_t img_height, int64_t img_width,
    double conf_thres, double nms_thres, int64_t maxBoxNum);

at::Tensor cnml_retina_detection_output_internal(
    const at::Tensor& loc_data, const at::Tensor& conf_data,
    const at::Tensor& prior_data, int64_t num_classes,
    int64_t background_label_id, double confidence_threshold,
    double nms_threshold, int64_t keep_topk, int batch_size,
    int num_preds_per_class, int boxNum, bool variance_encoded_in_target);

at::Tensor cnml_detretina_detection_output_internal(
    const at::Tensor& loc_data, const at::Tensor& conf_data,
    const at::Tensor& prior_data, const at::Tensor& topk_indices,
    int64_t num_classes, int64_t background_label_id,
    double confidence_threshold, double nms_threshold, int64_t nms_topk,
    int64_t keep_topk, double bbox_xform_clip, int batch_size,
    int num_preds_per_class, int boxNum, bool variance_encoded_in_target);

at::Tensor cnml_multiscale_roialign_internal(
    torch::List<at::Tensor> input, const at::Tensor& roi, int64_t channels,
    int64_t pooled_height, int64_t pooled_width, int64_t image_height,
    int64_t image_width, int64_t sampling_ratio, int64_t roi_offset,
    int64_t canonical_scale, int64_t canonical_level, int64_t is_sub);

at::Tensor cnml_multiscale_roipool_internal(
    torch::List<at::Tensor> input, const at::Tensor& roi,
    const at::Tensor& im_info, int64_t pooled_height, int64_t pooled_width,
    int64_t roi_cols, int64_t roi_offset, int64_t k_min, int64_t k_max,
    int64_t canonical_scale, int64_t canonical_level);

at::Tensor cnml_roipool_internal(const at::Tensor& input,
                                 const at::Tensor& rois,
                                 torch::List<int64_t> pool_hw,
                                 double spatial_scale);

at::Tensor cnml_reorg_internal(const at::Tensor& input, int64_t stride,
                               std::vector<float> q_scale, int q_mode);

at::Tensor cnml_roialign_internal(const at::Tensor& input,
                                  const at::Tensor& rois,
                                  torch::List<int64_t> pool_hw,
                                  double spatial_scale,
                                  int64_t sampling_ratio);

at::Tensor cnml_warp_affine_internal(const at::Tensor& src_data,
                                     const at::Tensor& mat_data,
                                     const int64_t dst_h, const int64_t dst_w);

at::Tensor cnml_ssd_detection_output_internal(
    const at::Tensor& loc_data, const at::Tensor& conf_data,
    const at::Tensor& prior_data, int64_t num_classes,
    int64_t background_label_id, double confidence_threshold,
    double nms_threshold, int64_t nms_topk, int64_t keep_topk, int batch_size,
    int num_preds_per_class, int boxNum, bool variance_encoded_in_target);

at::Tensor cnml_detnet_proposal_internal(
    const at::Tensor& bbox_pred, const at::Tensor& scores,
    const at::Tensor& anchors, int64_t nms_num, int64_t top_k_num, int64_t im_h,
    int64_t im_w, float scale, float im_min_h, float im_min_w, float nms_scale,
    float nms_threshold, int batch_size, int anchor_num);

std::tuple<at::Tensor, at::Tensor> cnml_proposal_fpn_internal(
    torch::List<at::Tensor> bbox_pred, torch::List<at::Tensor> scores,
    const at::Tensor& anchors, int64_t batch_size, int64_t anchor_num,
    torch::List<int64_t> ws, torch::List<int64_t> hs, int64_t nms_num,
    int64_t top_k_num, int64_t im_h, int64_t im_w, int64_t level,
    double im_min_h, double im_min_w, double nms_scale, double nms_threshold,
    double TO_REMOVE);

at::Tensor cnml_image_detect_internal(const at::Tensor& bboxes,
                                      const at::Tensor& scores,
                                      const at::Tensor& proposals,
                                      int64_t roi_num, int64_t num_class,
                                      int64_t image_h, int64_t image_w,
                                      double scale, double nms_thres,
                                      double score_thres, double TO_REMOVE);

std::tuple<at::Tensor, at::Tensor> cnml_bert_squad_internal(
    const at::Tensor& input_ids, const at::Tensor& token_ids,
    const at::Tensor& attention_mask, const at::Tensor& word_embedding_table,
    const at::Tensor& segment_embedding_table,
    const at::Tensor& position_embedding_table,
    const at::Tensor& layernorm_beta, const at::Tensor& layernorm_gamma,
    const at::Tensor& post_output_kernel, const at::Tensor& post_output_bias,
    const at::Tensor& attr_kernel_q_ch0, const at::Tensor& attr_kernel_q_ch1,
    const at::Tensor& attr_kernel_q_ch2, const at::Tensor& attr_kernel_q_ch3,
    const at::Tensor& attr_bias_q, const at::Tensor& attr_kernel_k_ch0,
    const at::Tensor& attr_kernel_k_ch1, const at::Tensor& attr_kernel_k_ch2,
    const at::Tensor& attr_kernel_k_ch3, const at::Tensor& attr_bias_k,
    const at::Tensor& attr_kernel_v_ch0, const at::Tensor& attr_kernel_v_ch1,
    const at::Tensor& attr_kernel_v_ch2, const at::Tensor& attr_kernel_v_ch3,
    const at::Tensor& attr_bias_v, const at::Tensor& attr_output_kernel_ch0,
    const at::Tensor& attr_output_kernel_ch1,
    const at::Tensor& attr_output_kernel_ch2,
    const at::Tensor& attr_output_kernel_ch3,
    const at::Tensor& attr_output_bias, const at::Tensor& attr_layernorm_beta,
    const at::Tensor& attr_layernorm_gamma, const at::Tensor& inter_kernel_ch0,
    const at::Tensor& inter_kernel_ch1, const at::Tensor& inter_kernel_ch2,
    const at::Tensor& inter_kernel_ch3, const at::Tensor& inter_bias,
    const at::Tensor& output_kernel_ch0, const at::Tensor& output_kernel_ch1,
    const at::Tensor& output_kernel_ch2, const at::Tensor& output_kernel_ch3,
    const at::Tensor& output_bias, const at::Tensor& output_layernorm_beta,
    const at::Tensor& output_layernorm_gamma, const at::Tensor& fix_pos,
    int64_t batch_num, int64_t seq_num);

at::Tensor cnml_shuffle_channel_internal(const at::Tensor& input,
                                         int64_t group);

at::Tensor cnml_cast_internal(const at::Tensor& input,
                              cnmlCastType_t cast_type);

at::Tensor cnml_sub_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_sub_internal(const at::Tensor& self, at::Scalar other);

at::Tensor cnml_mul_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_mul_internal(const at::Tensor& self, at::Scalar other);

at::Tensor cnml_mm_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_bmm_internal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_zeros_like_internal(const at::Tensor& self,
                                    const at::TensorOptions& options);

std::tuple<at::Tensor, std::vector<at::Tensor>, std::vector<at::Tensor>>
cnml_lstm_internal(const at::Tensor& data,
                   const std::vector<at::Tensor>& hx_vec,
                   const std::vector<at::Tensor>& cx_vec,
                   torch::List<at::Tensor> params, bool has_biases,
                   bool batch_first, int64_t num_layers, bool bidirectional,
                   int seq_len, int batch_size, std::vector<float> q_scale,
                   int q_mode);

std::tuple<at::Tensor, std::vector<at::Tensor>> cnml_gru_internal(
    const at::Tensor& data, const std::vector<at::Tensor>& hx,
    torch::List<at::Tensor> params, bool has_biases, bool batch_first,
    int64_t num_layers, bool bidirectional, int seq_len, int batch_size,
    std::vector<float> q_scale, int q_mode);

std::tuple<at::Tensor, at::Tensor> cnml_gru_bangc_internal(
    const at::Tensor& data, const at::Tensor& hx,
    const at::Tensor& weight, const at::Tensor& bias,
    bool has_biases, bool batch_first,
    int64_t num_layers, bool bidirectional, int seq_len, int batch_size,
    int hidden_size, std::vector<float> q_scale, int q_mode);

std::tuple<at::Tensor, at::Tensor, at::Tensor> cnml_native_layer_norm_internal(
    const at::Tensor& input, const at::Tensor& weight, const at::Tensor& bias,
    int64_t M, int64_t N, double eps,
    std::vector<std::vector<int64_t>> cnml_size, int64_t normalized_shape_size);

at::Tensor cnml_crop_resize_internal(const at::Tensor& inputImg,
                                     const at::Tensor& cropParam,
                                     const at::Tensor& roiNum,
                                     const at::Tensor& padValues,
                                     torch::List<int64_t> srcWH,
                                     torch::List<int64_t> dstWH,
                                     const int64_t keepAspectRatio);

at::Tensor cnml_clone_internal(const at::Tensor& self, bool is_const = false);

at::Tensor cnml_yuv_to_rgb_internal(const at::Tensor& inputY,
                                    const at::Tensor& inputUV,
                                    const int64_t color_mode);

at::Tensor cnml_resize_yuv2rgb_internal(const at::Tensor& inputY,
                                        const at::Tensor& inputUV,
                                        torch::List<int64_t> dstWH,
                                        torch::List<int64_t> roi,
                                        const int64_t color_mode);

at::Tensor cnml_scatter_internal(const at::Tensor& input, int64_t dim,
                                 const at::Tensor& index,
                                 const at::Tensor& src);

at::Tensor cnml_scatter_internal(const at::Tensor& input, int64_t dim,
                                 const at::Tensor& index, at::Scalar src);

at::Tensor cnml_conv_bn_relu_internal(const at::Tensor& input,
                                      const at::Tensor& weight,
                                      const at::Tensor& bias,
                                      torch::List<int64_t> padding,
                                      torch::List<int64_t> stride,
                                      torch::List<int64_t> dilation,
                                      int64_t groups,
                                      std::vector<float> q_scale,
                                      int q_mode,
                                      const at::Tensor& gamma,
                                      const at::Tensor& beta,
                                      const at::Tensor& running_mean,
                                      const at::Tensor& running_var,
                                      double momentum,
                                      double eps);

at::Tensor cnml_convtranspose_bn_relu_internal(const at::Tensor& input,
                                               const at::Tensor& weight,
                                               const at::Tensor& bias,
                                               torch::List<int64_t> stride,
                                               torch::List<int64_t> padding,
                                               torch::List<int64_t> output_padding,
                                               int64_t groups,
                                               torch::List<int64_t> dilation,
                                               std::vector<float> q_scale,
                                               int q_mode,
                                               const at::Tensor& gamma,
                                               const at::Tensor& beta,
                                               const at::Tensor& running_mean,
                                               const at::Tensor& running_var,
                                               double momentum,
                                               double eps);
// fake mlu op, actually compute on CPU
at::Scalar cnml_local_scalar_dense(const at::Tensor& self);

// fake mlu op, actually compute on CPU
bool cnml_equal(const at::Tensor& self, const at::Tensor& other);

at::Tensor cnml_residualinresidualblock_internal(const at::Tensor & input,
                                                 const at::Tensor & shape,
                                                 torch::List<at::Tensor> weights,
                                                 torch::List<at::Tensor> bias,
                                                 const std::vector<float> q_scale,
                                                 int64_t q_mode);

at::Tensor cnml_sr_lastblock_internal(const at::Tensor & input,
                                      const at::Tensor & shape,
                                      const at::Tensor & input_add,
                                      const at::Tensor & weight_conv,
                                      const at::Tensor & weight_deconv,
                                      torch::List<at::Tensor> bias,
                                      std::vector<float> q_scale,
                                      int q_mode);

at::Tensor cnml_add_variable_internal(const at::Tensor & input1,
                                      const at::Tensor & input2,
                                      const at::Tensor & shape);

at::Tensor cnml_conv_variable_internal(const at::Tensor & input,
                                       const at::Tensor & weight,
                                       const at::Tensor & bias,
                                       torch::List<int64_t> padding,
                                       torch::List<int64_t> stride,
                                       torch::List<int64_t> dilation,
                                       int64_t groups,
                                       std::vector<float> q_scale,
                                       int q_mode,
                                       const at::Tensor & extra_info,
                                       int64_t convert_type,
                                       int64_t kernel_type);

at::Tensor cnml_conv_forward_select_best_kernel_internal(const at::Tensor & input,
                                                         const at::Tensor & weight,
                                                         torch::List<int64_t> padding,
                                                         torch::List<int64_t> stride,
                                                         torch::List<int64_t> dilation);

}  // namespace ops
}  // namespace cnml
}  // namespace torch_mlu
